require "active_support/duration"
require "support/form"

module Support
  class CaseContractsForm < Form
    option :supplier, optional: true
    option :started_at, Types::DateField, optional: true
    option :ended_at, Types::DateField, optional: true
    option :spend, optional: true
    option :duration, optional: true

    # @return [Hash]
    def to_h
      super.merge(duration: as_duration)
    end

    # @return [String, nil] value to two decimal places
    def spend
      sprintf("%.2f", super) if super
    end

  private

    # @return [ActiveSupport::Duration, nil]
    def as_duration
      ActiveSupport::Duration.months(duration) if duration
    end
  end
end
