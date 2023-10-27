class Support::Case::Summary
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations
  include Support::Case::Validation::HasNextKeyDate

  attribute :support_case
  attribute :request_type, :boolean
  attribute :category_id
  attribute :other_category
  attribute :query_id
  attribute :other_query
  attribute :request_text
  attribute :support_level
  attribute :procurement_stage_id
  attribute :value
  attribute :source
  attribute :project
  attribute :next_key_date
  attribute :next_key_date_description

  validates :category_id, presence: true, if: :request_type
  validates :query_id, presence: true, unless: :request_type
  validates :other_category, presence: true, if: -> { category_id == Support::Category.other_category_id }
  validates :other_query, presence: true, if: -> { query_id == Support::Query.other_query_id }
  validates :source, presence: true
  validates :value, numericality: true, if: -> { value.present? }

  def procurement_stage
    return if procurement_stage_id.nil?

    Support::ProcurementStage.find(procurement_stage_id)
  end

  def save!
    support_case.summarise(
      category_id:,
      other_category:,
      query_id:,
      other_query:,
      request_text:,
      support_level:,
      procurement_stage_id:,
      value:,
      source:,
      project:,
      next_key_date:,
      next_key_date_description:,
    )
  end
end
