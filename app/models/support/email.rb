module Support
  class Email < ApplicationRecord
    belongs_to :case, class_name: "Support::Case", optional: true

    scope :display_order, -> { order("sent_at DESC") }
    scope :my_cases, ->(agent) { where(case_id: agent.case_ids) }
  end
end
