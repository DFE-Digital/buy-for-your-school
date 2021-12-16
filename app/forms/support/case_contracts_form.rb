require "active_support/duration"
require "support/form"
require "types"

module Support
  class CaseContractsForm < Form
    # @return [ActiveSupport::Duration] interval type
    Duration = Types.Constructor(ActiveSupport::Duration) do |value|
      value.is_a?(ActiveSupport::Duration) ? value : ActiveSupport::Duration.months(value.to_i)
    end

    option :supplier, optional: true
    option :started_at, optional: true
    option :ended_at, optional: true
    option :spend, optional: true
    option :duration, Duration, optional: true

    # @return [Integer] duration in months used in form field
    def duration
      super.inspect.to_i
    end

    def to_h
      { **super, duration: as_duration }
    end

  private

    # @return [ActiveSupport::Duration] when persisted
    def as_duration
      instance_variable_get(:@duration)
    end
  end
end
