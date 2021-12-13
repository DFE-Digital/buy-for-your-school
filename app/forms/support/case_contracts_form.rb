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
  end
end
