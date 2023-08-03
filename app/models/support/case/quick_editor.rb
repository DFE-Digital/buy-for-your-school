class Support::Case::QuickEditor
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor(
    :support_case,
    :note,
    :support_level,
    :procurement_stage_id,
    :with_school,
  )

  def procurement_case? = support_case.category.present?

  def save!
    support_case.quick_edit(note:, support_level:, procurement_stage_id:, with_school:)
  end
end
