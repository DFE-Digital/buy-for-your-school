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
end
