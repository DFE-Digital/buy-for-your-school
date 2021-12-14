module Support
  class CaseContractsForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    option :supplier, optional: true
    option :started_at, optional: true
    option :ended_at, optional: true
    option :spend, optional: true
    option :duration, optional: true

    def months
      return unless duration.present?

      ActiveSupport::Duration.months(duration)
    end

    # @return [Hash] form parms
    def to_h
      self.class.dry_initializer.attributes(self)
          .except(:messages)
          .merge(duration: months)
    end
  end
end
