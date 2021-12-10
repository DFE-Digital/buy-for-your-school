module Support
  class CaseContractsForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    option :supplier, optional: true
    option :started_at, optional: true
    option :ended_at, optional: true
    option :spend, optional: true
    option :duration, optional: true
  end
end
