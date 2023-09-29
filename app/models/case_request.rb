class CaseRequest < ApplicationRecord
  include SchoolPickable
  include Presentable
  include CaseCreatable

  belongs_to :category, class_name: "Support::Category", optional: true
  belongs_to :query, class_name: "Support::Query", optional: true
  belongs_to :organisation, polymorphic: true, optional: true
  belongs_to :created_by, class_name: "Support::Agent", optional: true
  belongs_to :support_case, class_name: "Support::Case", optional: true

  has_many :engagement_case_uploads, class_name: "EngagementCaseUpload"

  enum source: { digital: 0, nw_hub: 1, sw_hub: 2, incoming_email: 3, faf: 4, engagement_and_outreach: 5, schools_commercial_team: 6, engagement_and_outreach_cms: 7 }
  enum creation_source: { default: 0, engagement_and_outreach_team: 5 }

  validates :first_name, :last_name, :email, :source, presence: true
  validates :phone_number, length: { maximum: 12 }
  validates :phone_number, format: /\A(0|\+?44)[12378]\d{8,9}\z/, if: -> { phone_number.present? }
  validate :discovery_method_validation
  validates :discovery_method_other_text, presence: true, if: -> { discovery_method == Support::Case.discovery_methods[:other] }
  validate :request_type_validation
  validates :procurement_amount, presence: true, numericality: { greater_than: 0.99 }
  validates :other_category, presence: true, if: -> { category_id == Support::Category.other_category_id }
  validates :other_query, presence: true, if: -> { query_id == Support::Query.other_query_id }

  attribute :creation_source, default: :default

  def completed?
    result = valid?
    errors.clear
    result
  end

private

  def request_type_validation
    return if category.present? || query.present?

    errors.add(:request_type, I18n.t("case_requests.validation.request_type"))
  end

  def discovery_method_validation
    return if Support::Case.discovery_methods.value?(discovery_method)

    errors.add(:discovery_method, I18n.t("case_requests.validation.discovery_method"))
  end
end
