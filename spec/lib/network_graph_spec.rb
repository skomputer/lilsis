require 'rails_helper'

describe NetworkGraph do

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
      expect(NetworkGraph.new(@e1.id).graph[:nodes]).to be_a Array
      expect(NetworkGraph.new(@e1.id).graph[:links]).to be_a Array
    end

    it 'generates correct node array' do
      nodes = NetworkGraph.new(@e1.id).graph[:nodes]
      expect(nodes.length).to eql 2
      expect(nodes[0]).to eql({id: @e1.id, name: 'e1'})
      expect(nodes[1]).to eql({id: @e2.id, name: 'e2'})
    end

    it 'generates correct link array' do
      links = NetworkGraph.new(@e1.id).graph[:links]
      expect(links.length).to eql 1
      expect(links[0]).to eql({relationship_id: @rel.id, source: @e1.id, target: @e2.id, title: 'connection'})
    end

  end

end
