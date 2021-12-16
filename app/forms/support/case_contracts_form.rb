require "active_support/duration"
require "support/form"
require "types"

module Support
  class CaseContractsForm < Form
    # custom type
    Duration = Types.Constructor(ActiveSupport::Duration) do |value|
      value.is_a?(ActiveSupport::Duration) ? value : ActiveSupport::Duration.months(value.to_i)
    end

    option :supplier, optional: true
    option :started_at, optional: true
    option :ended_at, optional: true
    option :spend, optional: true
    option :duration, Duration, optional: true

    # @return [Integer] duration in months
    def duration
      super.inspect.to_i
    end
  end
end
