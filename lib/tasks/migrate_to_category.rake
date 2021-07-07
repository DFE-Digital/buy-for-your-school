desc "Update all Journeys to use the Catering category."

task migrate_to_category: :environment do
  puts "Associating all Journeys to Catering category"
  return if Journey.none?

  catering_category = Category.find_or_create_by!(contentful_id: ENV["CONTENTFUL_DEFAULT_CATEGORY_ENTRY_ID"]) do |category|
    contentful_category = GetCategory.new(category_entry_id: category.contentful_id).call
    category.title = contentful_category.title
    category.liquid_template = contentful_category.combined_specification_template
  end
  Journey.update_all(category_id: catering_category.id)
  Category.reset_counters(catering_category.id, :journeys)

  puts "Done"
end
