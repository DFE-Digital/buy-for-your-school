class Frameworks::Framework < ApplicationRecord
  include Frameworks::ActivityLoggable
  include StatusChangeable
  include SpreadsheetImportable
  include Sourceable
  include Presentable
  include ActivityLogPresentable
  include ActivityEventLoggable
  include Filterable
  include Sortable
  include Searchable
  include Evaluatable

  belongs_to :provider
  belongs_to :provider_contact, optional: true
  belongs_to :proc_ops_lead, class_name: "Support::Agent", optional: true
  belongs_to :e_and_o_lead, class_name: "Support::Agent", optional: true

  has_many :evaluations
  has_many :framework_categories
  has_many :support_categories, through: :framework_categories,
                                after_add: :log_framework_category_added,
                                after_remove: :log_framework_category_removed

  validates :name_provider_combination_must_be_unique, presence: { message: "" }, on: :creation_form
  validates :url, presence: { message: "Enter the provider url of the framework" }, on: :creation_form
  validates :provider_reference, presence: { message: "Enter the provider reference of the framework" }, on: :creation_form
  validates :proc_ops_lead_id, presence: { message: "Please select a procurement operations lead" }, on: :creation_form
  validates :dfe_review_date, presence: { message: "Enter DfE review date" }, on: :creation_form
  validates :provider_start_date, presence: { message: "Enter provider start date" }, on: :creation_form
  validates :provider_end_date, presence: { message: "Enter provider end date" }, on: :creation_form

  def name_provider_combination_must_be_unique
    if name.blank?
      errors.add(:name, "Enter the name of the framework")
    end
    if provider_id.blank?
      errors.add(:provider_id, "Please select a provider")
    end
    if name && provider_id && Frameworks::Framework.where(name:, provider_id:).exists?
      errors.add(:name, "The combination of name and provider must be unique")
      errors.add(:provider_id, "")
    end
  end

  enum :lot, {
    single: 0,
    multi: 1,
  }
end
