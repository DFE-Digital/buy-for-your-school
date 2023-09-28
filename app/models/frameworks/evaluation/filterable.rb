module Frameworks::Evaluation::Filterable
  extend ActiveSupport::Concern

  included do
    scope :by_status, ->(statuses) { where(status: Array(statuses)) }
  end

  class_methods do
    def filtering(params = {})
      Frameworks::Evaluation::Filtering.new(params)
    end
  end
end
