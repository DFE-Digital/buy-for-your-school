class Frameworks::Evaluation::QuickEditor
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations
  include Validation::HasNextKeyDate

  attribute :frameworks_evaluation
  attribute :note
  attribute :next_key_date
  attribute :next_key_date_description

  def save!
    frameworks_evaluation.quick_edit(note:, next_key_date:, next_key_date_description:)
  end
end
