class Support::Case::Transferer
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attribute :support_case
  attribute :framework_id
  attribute :assignee_id

  validates :framework_id, presence: true
  validates :assignee_id, presence: true

  def save!
    support_case.transfer_to_framework_evaluation(framework_id:, assignee_id:)
  end
end
