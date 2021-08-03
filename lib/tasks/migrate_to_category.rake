desc "Update all Journeys to use the Catering category."

# TODO: add missing rake task spec
# TODO: test data migration and use Rollbar for logging
task migrate_to_category: :environment do
  puts "Associating all Journeys to Catering category"
  return if Journey.none?

  categories = Content::Client.new.by_type(:category)
  catering_entry = categories.find { |category| category.title == "Catering" }
  contentful_category = GetCategory.new(category_entry_id: catering_entry.id).call

  catering = Category.find_or_create_by!(contentful_id: catering_entry.id) do |category|
    category.title = contentful_category.title
    category.description = contentful_category.description
    category.liquid_template = contentful_category.combined_specification_template
  end

  Journey.update_all(category_id: catering.id)
  Category.reset_counters(catering.id, :journeys)

  puts "Done"
end
