module Support
  class CaseResolutionForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    option :notes, Types::Params::String, optional: true
  end
end
