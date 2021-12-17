require "active_support/duration"
require "support/form"
require "types"

module Support
  class CaseContractsForm < Form
    # @return [ActiveSupport::Duration, nil] interval type
    Duration = Types.Constructor(ActiveSupport::Duration) do |value|
      if value
        value.is_a?(ActiveSupport::Duration) ? value : ActiveSupport::Duration.months(value.to_i)
      end
    end

    option :supplier, optional: true
    option :started_at, optional: true
    option :ended_at, optional: true
    option :spend, optional: true
    option :duration, Duration, optional: true

    # @return [Integer, nil] duration in months used in form field
    def duration
      super.in_months.to_i if super
    end

    # @return [String, nil] value to two decimal places
    def spend
      sprintf("%.2f", super) if super
    end
  end
end
