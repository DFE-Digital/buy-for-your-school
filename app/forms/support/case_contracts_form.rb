require "active_support/duration"

module Support
  class CaseContractsForm < Form
    option :supplier, optional: true
    option :started_at, Types::DateField, optional: true
    option :ended_at, Types::DateField, optional: true
    option :spend, Types::DecimalField, optional: true
    option :duration, optional: true
    option :is_supplier_sme, optional: true

    # @return [Hash]
    def to_h
      super.merge(duration: as_duration)
    end

  private

    # @return [ActiveSupport::Duration, nil]
    def as_duration
      ActiveSupport::Duration.months(duration) if duration
    end
  end
end
