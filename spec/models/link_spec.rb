require 'rails_helper'
require 'pp'

describe Link, type: :model do
  it { should belong_to(:relationship) }
  it { should belong_to(:entity) }
  it { should belong_to(:related) }
  it { should have_many(:chained_links) }

  describe 'relationships through links' do
    before(:all) do
      DatabaseCleaner.start
      @e1 = create(:corp)
      @e2 = create(:corp)
      @rel = Relationship.create!(entity1_id: @e1.id, entity2_id: @e2.id, category_id: Relationship::DONATION_CATEGORY)
    end
    after(:all) { DatabaseCleaner.clean }

    it 'created links' do
      Link.last(2).each { |link| expect(link.relationship).to eql @rel }
    end

    it 'entity1 has one relationship' do
      expect(@e1.reload.relationships.count).to eql 1
    end

    it 'entity2 has one relationship' do
      expect(@e2.reload.relationships.count).to eql 1
    end
  end

  def setup_network
    @e1 = create(:corp, name: 'e1')
    @e2 = create(:corp, name: 'e2')
    @e3 = create(:corp, name: 'e3')
    @e4 = create(:corp, name: 'e4')
    @rel_between_1_2 = Relationship.create!(entity1_id: @e1.id, entity2_id: @e2.id, category_id: Relationship::DONATION_CATEGORY)
    @rel_between_2_3 = Relationship.create!(entity1_id: @e2.id, entity2_id: @e3.id, category_id: Relationship::DONATION_CATEGORY)
    @rel_between_3_4 = Relationship.create!(entity1_id: @e3.id, entity2_id: @e4.id, category_id: Relationship::DONATION_CATEGORY)
  end

  describe 'Entity Network' do
    before(:all) do
      DatabaseCleaner.start
      setup_network
    end

    after(:all) { DatabaseCleaner.clean }

    describe 'entity_network_simple' do
      it 'returns list of entity ids one and two degrees away from provided entity' do
        expect(Set.new(Link.entity_network_simple(@e1.id))).to eql Set.new([@e1.id, @e2.id, @e3.id])
      end

      it 'returns list if provided <entity> ' do
        expect(Set.new(Link.entity_network_simple(@e1))).to eql Set.new([@e1.id, @e2.id, @e3.id])
      end

      it 'returns list of entity models' do
        expect(Set.new(Link.entity_network_simple(@e1, true))).to eql Set.new([@e1, @e2, @e3])
      end
    end

    describe 'entity_network' do
      def e2_hash
        { @e2.id => {
          entity: { id: @e2.id, blurb: @e2.blurb, name: @e2.name, primary_ext: @e2.primary_ext },
          links: [{ degree: 1, relationship_id: @rel_between_1_2.id, related_through: nil }]
        } }
      end

      def e3_hash
        { @e3.id => {
          entity: { id: @e3.id, blurb: @e3.blurb, name: @e3.name, primary_ext: @e3.primary_ext },
          links: [{ degree: 2, relationship_id: @rel_between_2_3.id, related_through: @e2.id }]
        } }
      end

      it 'returns an hash with :links and :entity' do
        expect(Link.entity_network(@e1)).to be_a Hash
      end

      it 'has length of 2' do
        expect(Link.entity_network(@e1).length).to eql 2
      end

      it 'has entity hash and link array' do
        Link.entity_network(@e1).each do |_, val|
          expect(val.fetch(:entity)).to be_a Hash
          expect(val.fetch(:links)).to be_a Array
        end
      end

      it 'entity hashes have correct structure' do
        Link.entity_network(@e1).each do |_, val|
          expect(val[:entity]).to have_key :id
          expect(val[:entity]).to have_key :blurb
          expect(val[:entity]).to have_key :name
          expect(['Org', 'Person']).to include(val[:entity][:primary_ext])
        end
      end

      it 'link hashes have correct structure' do
        Link.entity_network(@e1).each do |_, val|
          val.fetch(:links).each do |link|
            expect([1, 2]).to include(link[:degree])
            expect(link).to have_key :relationship_id
            expect(link).to have_key :related_through
          end
        end
      end

      it 'reutrns correct data' do
        expect(Link.entity_network(@e1)).to eql e2_hash.merge(e3_hash)
      end
    end
  end # end describe 'Entity Network'

  describe 'connection_between' do
    before { setup_network }

    
  end
end
