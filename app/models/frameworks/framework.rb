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

  validates :name, :url, :provider_id, :proc_ops_lead_id, :provider_end_date, presence: true, on: %i[creation_form updation_form]
  validate :unique_name_and_provider, if: -> { name.present? }, on: :creation_form

  def unique_name_and_provider
    if name && provider_id && Frameworks::Framework.where(name:, provider_id:).exists?
      errors.add(:name, :unique_name_and_provider)
    end
  end

  enum :lot, {
    single: 0,
    multi: 1,
  }
end
