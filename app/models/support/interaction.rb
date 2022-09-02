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
    #   hub progress notes
    #   hub migration
    #   faf_support_request
    #   procurement_updated
    #   existing_contract_updated
    #   new_contract_updated
    #   savings_updated
    #   state_change
    enum event_type: {
      note: 0,
      phone_call: 1,
      email_from_school: 2,
      email_to_school: 3,
      support_request: 4,
      hub_notes: 5,
      hub_progress_notes: 6,
      hub_migration: 7,
      faf_support_request: 8,
      procurement_updated: 9,
      existing_contract_updated: 10,
      new_contract_updated: 11,
      savings_updated: 12,
      state_change: 13,
      email_merge: 14,
      create_case: 15,
    }

    validates :body, presence: true, unless: proc { |a| a.support_request? || a.faf_support_request? }

    default_scope { order(created_at: :desc) }

    scope :messages, -> { where(event_type: %i[email_from_school email_to_school phone_call]) }

    scope :case_history, -> { where.not(event_type: %i[email_from_school email_to_school phone_call]) }

    scope :templated_messages, -> { where(event_type: %i[email_from_school email_to_school]).where("additional_data::jsonb ? 'email_template'").order(created_at: :desc) }

    scope :logged_contacts, -> { where(event_type: %i[email_from_school email_to_school phone_call]).where("additional_data::text = '{}'::text").order(created_at: :desc) }

    def email
      return unless additional_data.key?("email_id")

      Support::Email.find(additional_data["email_id"])
    end
  end
end
