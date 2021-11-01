# frozen_string_literal: true

module Support
  #
  # Types of interactions as per `event type` or "things appearing in the case history tab"
  #
  class Interaction < ApplicationRecord
    #
    # This is a temp fix so Rails form_with model can infer the correct paths from the model name
    # I believe this can be fixed be replacing the namespace support route to use a scope instead
    # However this will need further investigation as it will impact all routes within support
    #
    def self.model_name
      ActiveModel::Name.new("Support::Interaction", nil, "Interaction")
    end

    #
    # See InteractionsController.safe_interaction
    #
    #  @return [Array]
    SAFE_INTERACTIONS = %w[note contact].freeze

    belongs_to :agent, class_name: "Support::Agent", optional: true
    belongs_to :case, class_name: "Support::Case"

    # Event Type
    #
    #   note (default)
    #   phone_call
    #   email_from_school
    #   email_to_school
    #   support_request
    #   hub notes
    #   progress notes
    enum event_type: {
      note: 0,
      phone_call: 1,
      email_from_school: 2,
      email_to_school: 3,
      support_request: 4,
      hub_notes: 5,
      progress_notes: 6,
    }

    validates :body, presence: true, unless: proc { |a| a.support_request? }

    default_scope { order(created_at: :desc) }
  end
end
