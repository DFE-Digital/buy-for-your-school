module Support
  class CaseClosureForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    # @!attribute [r] reason
    # @return [String]
    option :reason, Types::Params::String, optional: true
  end
end
