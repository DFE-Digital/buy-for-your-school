module Frameworks::Framework::Filterable
  extend ActiveSupport::Concern

  included do
    scope :by_status, ->(statuses) { where(status: Array(statuses)) }
    scope :by_provider, ->(provider_ids) { where(provider_id: Array(provider_ids)) }
    scope :by_category, ->(category_ids) { joins(:framework_categories).where(framework_categories: { support_category_id: Array(category_ids) }) }
    scope :by_e_and_o_lead, ->(e_and_o_lead_ids) { where(e_and_o_lead_id: Array(e_and_o_lead_ids)) }
    scope :by_proc_ops_lead, ->(proc_ops_lead_ids) { where(proc_ops_lead_id: Array(proc_ops_lead_ids)) }
    scope :by_provider_contact, ->(provider_contact_ids) { where(provider_contact_id: Array(provider_contact_ids)) }
  end

  class_methods do
    def filtering(params = {})
      Frameworks::Framework::Filtering.new(params)
    end
  end
end
