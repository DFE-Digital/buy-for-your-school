# frozen_string_literal: true

module Support
  #
  # An existing contract between a school and an organisation
  #
  class ExistingContract < Contract
    before_save :calculate_started_at
    has_one :support_case, class_name: "Support::Case"

    # Perform start date calculation based on ended_at and duration
    #
    # @return [Date, nil]
    def calculate_started_at
      return unless ended_at && duration

      self.started_at = ended_at - duration
    end
  end
end
