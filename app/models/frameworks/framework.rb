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

  belongs_to :provider
  belongs_to :provider_contact, optional: true
  belongs_to :proc_ops_lead, class_name: "Support::Agent", optional: true
  belongs_to :e_and_o_lead, class_name: "Support::Agent", optional: true

  has_many :framework_categories
  has_many :support_categories, through: :framework_categories,
                                after_add: :log_framework_category_added,
                                after_remove: :log_framework_category_removed

  validates :provider_id, presence: { message: "Please select a provider" }, on: :creation_form
  validates :provider_contact_id, presence: { message: "Please select a contact" }, on: :creation_form

  enum lot: {
    single: 0,
    multi: 1,
  }
end
