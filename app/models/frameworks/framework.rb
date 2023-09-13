class Frameworks::Framework < ApplicationRecord
  include Frameworks::ActivityLoggable
  include StatusChangeable
  include SpreadsheetImportable
  include Sourceable
  include Presentable
  include ActivityLogPresentable
  include Filterable
  include Sortable

  belongs_to :provider
  belongs_to :provider_contact, optional: true
  belongs_to :proc_ops_lead, class_name: "Support::Agent", optional: true
  belongs_to :e_and_o_lead, class_name: "Support::Agent", optional: true
  belongs_to :support_category, class_name: "Support::Category", optional: true

  validates :provider_id, presence: { message: "Please select a provider" }, on: :creation_form
  validates :provider_contact_id, presence: { message: "Please select a contact" }, on: :creation_form

  enum lot: {
    single: 0,
    multi: 1,
  }
end
