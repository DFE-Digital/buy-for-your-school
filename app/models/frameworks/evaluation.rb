class Frameworks::Evaluation < ApplicationRecord
  include Frameworks::ActivityLoggable
  include Filterable
  include Sortable
  include StatusChangeable
  include Presentable
  include ActivityLogPresentable

  belongs_to :framework
  has_one :provider, through: :framework
  belongs_to :assignee, class_name: "Support::Agent"
  belongs_to :contact, class_name: "Frameworks::ProviderContact", optional: true

  def email_prefix
    "[#{reference}]"
  end
end
