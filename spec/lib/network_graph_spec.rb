require 'rails_helper'

describe NetworkGraph do

  before(:all) { DatabaseCleaner.start } 
  after(:all) { DatabaseCleaner.clean } 

  describe 'initialize' do

    before do
      @e = build(:person, id: rand(100) )
      expect(Entity).to receive(:find).with(@e.id).and_return(@e).once
    end

    it 'sets entity' do
      expect(NetworkGraph.new(@e.id).entity).to eql @e
    end

    it 'sets relationship limit to be the default' do
      expect(NetworkGraph.new(@e.id).relationship_limit).to eql NetworkGraph::DEFAULT_RELATIONSHIP_LIMIT
    end

    it 'allows the relationship limit to be changed' do
      expect(NetworkGraph.new(@e.id, 100).relationship_limit).to eql 100
    end

    it 'allows the relationship limit to be set to nil' do
      expect(NetworkGraph.new(@e.id, nil).relationship_limit).to be nil
    end

  end

  describe 'graph' do
    before do
      @e1 = build(:person, id: rand(1000),  name: 'e1')
      @e2 = build(:person, id: rand(1000), name: 'e2')
      @rel = build(:generic_relationship, entity: @e1, related: @e2, description1: 'connection', id: rand(100))
      allow(@e1).to receive(:relationships).and_return( double(:limit => [@rel]))
      allow(Entity).to receive(:find).with(@e1.id).and_return(@e1)
    end

    it 'returns hash with array of nodes and links' do
      expect(NetworkGraph.new(@e1.id).graph).to be_a Hash
      expect(NetworkGraph.new(@e1.id).graph[:nodes]).to be_a Set
      expect(NetworkGraph.new(@e1.id).graph[:links]).to be_a Set
    end

    it 'generates correct node array' do
      nodes = NetworkGraph.new(@e1.id).graph[:nodes]
      expect(nodes.length).to eql 2
      expect(nodes).to include({id: @e1.id, name: 'e1'})
      expect(nodes).to include({id: @e2.id, name: 'e2'})
    end

    it 'generates correct link array' do
      links = NetworkGraph.new(@e1.id).graph[:links]
      expect(links.length).to eql 1
      expect(links).to include({relationship_id: @rel.id, source: @e1.id, target: @e2.id, title: 'connection'})
    end
  end

  describe "includes the entity's relationships's relationships" do
    # There are 4 entities and 4 relationships
    # E1 -> E2 & E3
    # E2 -> E1, E3 & E4
    # E3 -> E1, E2, E4
    # E4 -> E4, E3
    # When the network graph is centered around E1, it should include the relationship between
    # E2 & E3, because E3 is also connected to E1, but it should not include the relationship between E3 & E4
    before(:all) do 
      @e1 = create(:corp, name: 'e1')
      @e2 = create(:corp, name: 'e2')
      @e3 = create(:corp, name: 'e3')
      @e4 = create(:corp, name: 'e4')
      
      @rel1 = create(:generic_relationship, entity: @e1, related: @e2)
      @rel2 = create(:generic_relationship, entity: @e2, related: @e3)
      @rel3 = create(:generic_relationship, entity: @e1, related: @e3)
      @rel4 = create(:generic_relationship, entity: @e3, related: @e4)
      
      @graph = NetworkGraph.new(@e1.id).graph
      @entity_ids = @graph[:nodes].map{ |n| n[:id] } 
      @rel_ids = @graph[:links].map{ |r| r[:relationship_id] } 
    end

    it 'contains 3 nodes' do
      expect(@graph[:nodes].length).to eql 3
    end
    
    it 'contains 3 links' do
      expect(@graph[:links].length).to eql 3
    end

    it 'contains e1, e2, & e3' do
      [@e1,@e2,@e3].each { |e| expect(@entity_ids.include?(e.id)).to be true } 
    end

    it 'does not contain e4' do
      expect(@entity_ids.include?(@e4.id)).to be false
    end

    it 'contains rel 1, 2, 3, but not 4' do
      [@rel1,@rel2,@rel3].each { |r| expect(@rel_ids.include?(r.id)).to be true }
      expect(@rel_ids.include?(@e4.id)).to be false
    end
    
    
  end

  
end
