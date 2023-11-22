module Frameworks::Evaluation::Filterable
  extend ActiveSupport::Concern

  included do
    scope :by_status, ->(statuses) { where(status: Array(statuses)) }
    scope :by_provider, ->(provider_ids) { joins(:framework).where(framework: { provider_id: Array(provider_ids) }) }
    scope :by_category, ->(category_ids) { joins(:framework).merge(Frameworks::Framework.by_category(category_ids)) }
  end

  class_methods do
    def filtering(params = {})
      Frameworks::Evaluation::Filtering.new(params)
    end
  end
end
