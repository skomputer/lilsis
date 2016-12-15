=begin

This generates a graph of relationship data for the provided entity.
It is intended to be used in a D3 graph, but it could be used other purposes.

Use: 
NetwokGraph.new(id).graph -> returns hash of relationships in this format

By default it uses a relationship limit of 10, you can pass in a different limit or use nil for unlimited
NetwokGraph.new(id, 50) -> limit of 50
NetworkGraph.new(id, nil) -> no limit

{ 
  nodes: [
           {
              id: int (entity.id),
              name: str (entityname)
           }
         ]

  links: [
           {
              relationship_id: int,
              source: int (entity1_id),
              target: int (entity2_id)
              title: str     
            }
         ]
}

The source and target fields are both node id numbers.

=end
class NetworkGraph
  DEFAULT_RELATIONSHIP_LIMIT = 10
  attr_reader :entity, :relationship_limit 
  
  # input: integer (id), int | nil.
  # set relationship limit to nil to remove the limit
  def initialize(id, relationship_limit=DEFAULT_RELATIONSHIP_LIMIT)
    @entity = Entity.find(id)
    @relationship_limit = relationship_limit
    @relationships = relationships(id).limit(@relationship_limit)
    @related_entities_ids = @relationships.map { |r| entity_from_relationship(r).id }
  end

  def graph
    nodes = Set.new.add(entity_hash @entity)
    links = Set.new
    @relationships.each do |relationship|
      links.add(link_hash relationship) # add relationship to link
      other_entity = entity_from_relationship(relationship)
      nodes.add(entity_hash other_entity) # add related entity to nodes
      
      # search the other entity's relationships and
      # add the relationships of the other entity only if it's with 
      # an entity that is also connected to the initial entity (@entity)
      relationships(other_entity.id).each do |r|
          other_entity_relationship_partner = entity_from_relationship(r, other_entity) 
          links.add(link_hash r) if is_also_connected_to(other_entity_relationship_partner)
      end
    end
    { nodes: nodes, links: links }
  end

  private

  def is_also_connected_to(e)
    @related_entities_ids.include?(e.id) unless e.nil?
  end

  def relationships(id)
    Relationship.includes(:entity, :related).where("is_deleted = 0 AND (entity1_id = ? OR entity2_id = ?)", id, id)
  end

  def link_hash(rel)
    {
      relationship_id: rel.id,
      source: rel.entity1_id,
      target: rel.entity2_id,
      title: rel.title
    }
  end

  # Returns the *other* person/org in the relationship
  def entity_from_relationship(rel, who_not_to_select=@entity)
    return (rel.entity == who_not_to_select) ? rel.related : rel.entity
  end

  def entity_hash(entity)
    {
      id: entity.id,
      name: entity.name
    }
  end
  
end
