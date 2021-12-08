module Support
  class CaseContractsForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    option :type, optional: true
    option :supplier, optional: true
    option :started_at, optional: true
    option :ended_at, optional: true
    option :spend, optional: true
  end
end