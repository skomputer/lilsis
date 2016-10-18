namespace :query do
  desc "Bankers"
  task bankers: :environment do

    ids = Set.new
    names = Set.new

    List.find(733).list_entities.map { |x| x.entity.name }.each do |name|
      names.add name
      names.add name.gsub(/Management/i, "").strip
      names.add name.gsub(/Management/i, "mgmt").strip
      names.add name.gsub(/llc/i, "").gsub(',', '').strip
      names.add name.gsub(',', "").strip
      names.add name.gsub('.', "").strip
      names.add name.gsub(/L\.P\./i, "").strip
      names.add name.gsub(/L\.L\.C\./i, "").strip
      names.add name.gsub(/L\.L\.C\./i, "LLC").strip
      names.add name.gsub(/inc/i, "").gsub('.', '').strip
    end
    
    names.each do |name|
      OsDonation.search_for_ids(name, :per_page => 50000).each { |id| ids.add(id) }
    end
    
    CSV.open(Rails.root.join('pr_bankers.csv'), 'w') do |csv|
      csv << OsDonation.attribute_names
      ids.each do |id|
        csv << OsDonation.find(id).attributes.values
      end 
    end

  end

end
