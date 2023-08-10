class Support::Case::QuickEditor
  include ActiveModel::Model
  include ActiveModel::Validations
  include Support::Case::Validation::HasNextKeyDate

  attr_accessor(
    :support_case,
    :note,
    :support_level,
    :procurement_stage_id,
    :with_school,
    :next_key_date,
    :next_key_date_description,
  )

  def procurement_case? = support_case.category.present?

  def save!
    support_case.quick_edit(note:, support_level:, procurement_stage_id:, with_school:, next_key_date:, next_key_date_description:)
  end
end
