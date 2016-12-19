class Link < ActiveRecord::Base
  include SingularTable

  belongs_to :relationship, inverse_of: :links
  belongs_to :entity, foreign_key: "entity1_id", inverse_of: :links
  belongs_to :related, class_name: "Entity", foreign_key: "entity2_id", inverse_of: :reverse_links
  has_many :chained_links, class_name: "Link", foreign_key: "entity1_id", primary_key: "entity2_id"

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
  def self.entity_network(entity, return_as_entity=false)
    one_degree_ids = entity2_ids( entity.is_a?(Numeric) ? entity : entity.id)
    one_and_two_degree_ids = (entity2_ids(one_degree_ids) + one_degree_ids).uniq
    return_as_entity ? Entity.find(one_and_two_degree_ids) : one_and_two_degree_ids
  end

  #  Int or [int] -> [int]
  private_class_method  def self.entity2_ids(ids)
    where(entity1_id: ids).map(&:entity2_id)
  end
    
end
