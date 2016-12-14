=begin

This generates a graph of relationship data for the provided entity.
It is intended to be used in a D3 graph, but it could be used other purposes.

Use: 
NetwokGraph.new(id).graph -> returns hash of relationships in this formate

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
              target: int (rentity2_id)
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
  end

  def graph
    nodes = [ entity_hash ]
    links = Array.new
    @entity.relationships.limit(@relationship_limit).each do |rel|
      nodes.append(entity_from_relationship rel)
      links.append(link_hash rel)
    end
    { nodes: nodes, links: links }
  end

  private

  def link_hash(rel)
    {
      relationship_id: rel.id,
      source: rel.entity1_id,
      target: rel.entity2_id,
      title: rel.title
    }
  end

  # Returns the *other* person in the relationship
  def entity_from_relationship(rel)
    entity_hash (rel.entity == @entity) ? rel.related : rel.entity
  end

  def entity_hash(entity=@entity)
    {
      id: entity.id,
      name: entity.name
    }
  end
  
end
