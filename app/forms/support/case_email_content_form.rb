module Support
  class CaseEmailContentForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    option :email_body, Types::Params::String, optional: true
  end
end
