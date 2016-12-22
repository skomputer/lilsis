require 'rails_helper'

describe NetworkGraph do
  before(:all) do
    Entity.skip_callback(:create, :after, :create_primary_ext)
    DatabaseCleaner.start
  end
  after(:all) do
    Entity.set_callback(:create, :after, :create_primary_ext)
    DatabaseCleaner.clean
  end

  describe 'initialize' do
    before do
      @e = build(:person, id: rand(100) )
      # expect(Entity).to receive(:includes).and_return(double(:find => @e))
      expect(Entity).to receive(:find).and_return(@e)
      expect(Relationship).to receive(:includes)
                               .and_return(double(:where => double(limit: [])))
    end

    it 'sets entity' do
      expect(NetworkGraph.new(@e.id).entity).to eql @e
    end

    it 'sets relationship limit to be the default' do
      expect(NetworkGraph.new(@e.id).relationship_limit)
        .to eql NetworkGraph::DEFAULT_RELATIONSHIP_LIMIT
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
      @e1 = create(:person, name: 'e1')
      @e2 = create(:person, name: 'e2')
      @rel = create(:generic_relationship, entity: @e1, related: @e2, description1: 'connection')
    end

    it 'returns hash with set of nodes and links' do
      expect(NetworkGraph.new(@e1.id).graph).to be_a Hash
      expect(NetworkGraph.new(@e1.id).graph[:nodes]).to be_a Set
      expect(NetworkGraph.new(@e1.id).graph[:links]).to be_a Set
    end

    it 'generates correct node set' do
      nodes = NetworkGraph.new(@e1.id).graph[:nodes]
      expect(nodes.length).to eql 2
      expect(nodes).to include(id: @e1.id, name: 'e1')
      expect(nodes).to include(id: @e2.id, name: 'e2')
    end

    it 'generates correct link set' do
      links = NetworkGraph.new(@e1.id).graph[:links]
      expect(links.length).to eql 1
      expect(links).to include(relationship_id: @rel.id, source: @e1.id, target: @e2.id, title: 'connection')
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
      @entity_ids = @graph[:nodes].map { |n| n[:id] }
      @rel_ids = @graph[:links].map { |r| r[:relationship_id] }
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
      [@rel1, @rel2, @rel3].each { |r| expect(@rel_ids.include?(r.id)).to be true }
      expect(@rel_ids.include?(@e4.id)).to be false
    end

    context 'the graph for e4' do
      let(:e4_graph) { NetworkGraph.new(@e4.id).graph }

      it 'should have 2 nodes' do
        expect(e4_graph[:nodes].length).to eql 2
      end

      it 'should have 1 link' do
        expect(e4_graph[:links].length).to eql 1
      end
    end
  end
end
