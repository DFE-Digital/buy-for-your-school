module Support
  class CaseSummaryForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    option :support_level, optional: true
    option :value, optional: true
  end
end
