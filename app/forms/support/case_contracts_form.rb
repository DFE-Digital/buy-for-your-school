require "active_support/duration"
require "support/form"
require "types"

module Support
  class CaseContractsForm < Form
    # @return [ActiveSupport::Duration] interval type
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

    # @return [Integer] duration in months used in form field
    def duration
      if super.is_a?(ActiveSupport::Duration)
        super.in_months.to_i
      end
    end
  end
end
