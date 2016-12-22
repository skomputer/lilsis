class Link < ActiveRecord::Base
  include SingularTable

  belongs_to :relationship, inverse_of: :links
  belongs_to :entity, foreign_key: 'entity1_id', inverse_of: :links
  belongs_to :related, class_name: 'Entity', foreign_key: 'entity2_id', inverse_of: :reverse_links
  has_many :chained_links, class_name: 'Link', foreign_key: 'entity1_id', primary_key: 'entity2_id'

  def self.interlock_hash_from_entities(entity_ids)
    interlock_hash(where(entity1_id: entity_ids))
  end

  def self.interlock_hash(links)
    links.reduce({}) do |hash, link|
      hash[link.entity2_id] = hash.fetch(link.entity2_id, []).push(link.entity1_id).uniq
      hash
    end
  end

  # NOTE: Link might not be the best model to stick this on. It should probably go on entity, but entity is such a crowded model...
  # int | <Entity> -> [ <Entity> ]
  # Returns entities that are within one and two degrees away from the provided entity
  def self.entity_network_simple(entity, return_as_entity = false, limit = nil)
    one_degree_ids = entity2_ids entity_id(entity)
    one_and_two_degree_ids = (entity2_ids(one_degree_ids) + one_degree_ids).uniq
    return_as_entity ? Entity.where(id: one_and_two_degree_ids).limit(limit) : one_and_two_degree_ids
  end

  # Returns a hash of related entities with the following structure:
  # {
  #  int(entity_id): {
  #           entity: {
  #             id: int,
  #             blurb: str,
  #             name: str
  #             primary_ext: org
  #           },
  #           links: [
  #             {
  #               degree: 1|2,
  #               relationship_id:int,
  #               related_through: nil | entity_id
  #             }
  #           ]
  #         }
  # }
  #
  # input: int | <Entity>
  def self.entity_network(e)
    network_entities = Hash.new 
    # get all first degree entities, relationships that have a direct connection with the given entity
    one_degree_links = includes(:related).where(entity1_id: entity_id(e))
    one_degree_ids = one_degree_links.map(&:entity2_id)
    one_degree_relationships = one_degree_links.map(&:relationship_id)
    # get second degree links, removing those links representing relationships that are one degree links
    two_degree_links = includes(:related).where(entity1_id: one_degree_ids).to_a.delete_if { |l| one_degree_relationships.include?(l.relationship_id) }

    one_degree_links.each do |link|
      entity = link.related
      next if entity.nil?
      if network_entities[entity.id]
        network_entities[entity.id][:links].push link_hash(link, 1)
      else
        network_entities[entity.id] = {
          entity: e_hash(entity),
          links: [link_hash(link, 1)]
        }
      end
    end

    two_degree_links.each do |link|
      related_through_id = link.entity1_id
      entity = link.related
      next if entity.nil?
      if network_entities[entity.id]
        network_entities[entity.id][:links].push link_hash(link, 2, related_through_id)
      else
        network_entities[entity.id] = {
          entity: e_hash(entity),
          links: [link_hash(link, 2, related_through_id)]
        }
      end
    end

    network_entities
  end

  private_class_method def self.link_hash(link, degree, related_through = nil)
    {
      degree: degree,
      relationship_id: link.relationship_id,
      related_through: related_through
    }
  end

  private_class_method def self.e_hash(e)
    {
      id: e.id,
      blurb: e.blurb,
      name: e.name,
      primary_ext: e.primary_ext
    }
  end

  private_class_method def self.entity2_ids(ids)
    where(entity1_id: ids).map(&:entity2_id)
  end

  private_class_method def self.entity_id(entity)
    entity.is_a?(Numeric) ? entity : entity.id
  end
end
