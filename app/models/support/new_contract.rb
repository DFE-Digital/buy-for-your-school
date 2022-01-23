# frozen_string_literal: true

module Support
  #
  # A (potential) new contract between a school and an organisation
  #
  class NewContract < Contract
    before_save :calculate_ended_at
    has_one :support_case, class_name: "Support::Case"

    # Perform end date calculation based on started_at and duration
    #
    # @return [Date, nil]
    def calculate_ended_at
      return unless started_at && duration

      self.ended_at = started_at + duration
    end
  end
end
