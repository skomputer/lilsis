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

end
