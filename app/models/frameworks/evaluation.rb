class Frameworks::Evaluation < ApplicationRecord
  include Frameworks::ActivityLoggable
  include EmailTicketable
  include EmailMovable
  include Filterable
  include Sortable
  include StatusChangeable
  include Presentable
  include Noteable
  include QuickEditable
  include Sourceable
  include Transferable

  belongs_to :framework
  has_one :provider, through: :framework
  belongs_to :assignee, class_name: "Support::Agent"
  belongs_to :contact, class_name: "Frameworks::ProviderContact", optional: true

  alias_attribute :ref, :reference

  before_save do
    # prevent activity log items for "none"-changes
    self.next_key_date_description = nil if changes.key?(:next_key_date_description) && next_key_date_description == ""
  end
end
