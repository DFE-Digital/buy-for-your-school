module Support
  class CaseEmailTypeForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    # @!attribute [r] choice
    # @return [String]
    option :choice, Types::Params::String, optional: true
  end
end
