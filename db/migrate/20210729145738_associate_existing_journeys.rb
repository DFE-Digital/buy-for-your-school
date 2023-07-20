class AssociateExistingJourneys < ActiveRecord::Migration[6.1]
  def up
    # empty database
    return if Journey.none? && Category.none?
    # transition from single to multi-category
    return if Journey.where(category_id: nil).none? && Category.one?

    Journey.count
    Journey.where(category_id: nil).count

    catering_entry = Content::Client.new.by_slug(:category, "catering")
    contentful_category = GetCategory.new(category_entry_id: catering_entry.id).call

    Category.create!(
      title: contentful_category.title,
      description: contentful_category.description,
      liquid_template: contentful_category.combined_specification_template,
      contentful_id: contentful_category.id,
    )

    catering = Category.where(contentful_id: catering_entry.id).first

    Journey.where(category_id: nil).update_all(category_id: catering.id)

    Category.reset_counters(catering.id, :journeys)
  end

  def down; end
end
