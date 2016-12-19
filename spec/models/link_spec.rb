require 'rails_helper'

describe Link, type: :model do

  it { should belong_to(:relationship) }
  it { should belong_to(:entity) }
  it { should belong_to(:related) }
  it { should have_many(:chained_links) }

  describe 'relationships through links' do
    before(:all) do
      @e1 = create(:corp)
      @e2 = create(:corp)
      @rel = Relationship.create!(entity1_id: @e1.id, entity2_id: @e2.id, category_id: Relationship::DONATION_CATEGORY)
    end

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

  describe 'entity_network' do
    before(:all) do
      @e1 = create(:corp)
      @e2 = create(:corp)
      @e3 = create(:corp)
      @e4 = create(:corp)
      @rel_between_1_2 = Relationship.create!(entity1_id: @e1.id, entity2_id: @e2.id, category_id: Relationship::DONATION_CATEGORY)
      @rel_between_2_3 = Relationship.create!(entity1_id: @e2.id, entity2_id: @e3.id, category_id: Relationship::DONATION_CATEGORY)
      @rel_between_3_4 = Relationship.create!(entity1_id: @e3.id, entity2_id: @e4.id, category_id: Relationship::DONATION_CATEGORY)
      
    end
    
    it 'returns list of entity ids one and two degrees away from provided entity' do
      expect(Set.new(Link.entity_network(@e1.id))).to eql Set.new([@e1.id, @e2.id, @e3.id])
    end

    it 'returns list if provided <entity> ' do
      expect(Set.new(Link.entity_network(@e1))).to eql Set.new([@e1.id, @e2.id, @e3.id])
    end

    it 'returns list of entity models' do
      expect(Set.new(Link.entity_network(@e1, true))).to eql Set.new([@e1, @e2, @e3])
    end

  end

end
