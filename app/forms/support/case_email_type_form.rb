module Support
  class CaseEmailTypeForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    option :choice, Types::Params::String, optional: true
  end
end
