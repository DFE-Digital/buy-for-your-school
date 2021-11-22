module Support
  class CaseResolutionForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    # @!attribute [r] notes
    # @return [String]
    option :notes, Types::Params::String, optional: true
  end
end
