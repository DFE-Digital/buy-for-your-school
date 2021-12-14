module Support
  class CaseContractsForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    option :supplier, optional: true
    option :started_at, optional: true
    option :ended_at, optional: true
    option :spend, optional: true
    option :duration_in_months, optional: true

    option :duration, optional: true, default: proc {
      ActiveSupport::Duration.months(duration_in_months) if duration_in_months
    }

    # @return [Hash] form parms
    def to_h
      self.class.dry_initializer.public_attributes(self)
          .except(:messages, :duration_in_months)
    end
  end
end
