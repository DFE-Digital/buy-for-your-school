# frozen_string_literal: true

module Support
  class Interaction < ApplicationRecord
    def self.model_name
      ActiveModel::Name.new("Support::Interaction", nil, "Interaction")
    end

    SAFE_INTERACTIONS = %w[note contact].freeze

    belongs_to :agent, class_name: "Support::Agent"
    belongs_to :case, class_name: "Support::Case"

    # Event Type
    #
    #   note (default)
    #   phone_call
    #   email_from_school
    #   email_to_school
    enum event_type: { note: 0, phone_call: 1, email_from_school: 2, email_to_school: 3 }

    validates :body, presence: true

    default_scope { order(created_at: :desc) }
  end
end
