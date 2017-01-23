namespace :lincoln_club do
  desc 'bulk upload'
  task bulk: :environment do
    CSV.foreach(Rails.root.join('data', 'lincoln_club.csv'), headers: true) do |row|
      e = Entity.find_by_id(row['entity_id'])

      if e.present?
        company = Entity.create(name: row['company'], primary_ext: 'Org', last_user_id: 1) if row['company_id'].blank?
        company = Entity.find_by_id(row['company_id']) if row['company_id'].present?
        
        if company.present? && company.persisted?
          rel = Relationship.create(entity1_id: e.id, entity2_id: company.id, category_id: 1, description1: 'Employee', description2: 'Employee', last_user_id: 1)
          puts "failed to create relationship for : #{row['company']}" unless rel.persisted?
          Reference.create(source: 'https://sdlincolnclub.com/membership/board-of-directors/', name: 'SD Lincoln Club - Board of Directors', object_id: rel.id, object_model: "Relationship") if rel.persisted?
        else
          puts "failed to find or create the company: #{row['company']}"
        end

      else
        puts "could not find entity with id: #{row['entity_id']}"
      end

    end
  end
end
