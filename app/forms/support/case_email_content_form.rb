module Support
  class CaseEmailContentForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    # @!attribute [r] email_body
    # @return [String]
    option :email_body, Types::Params::String, optional: true
    # @!attribute [r] email_subject
    # @return [String]
    option :email_subject, Types::Params::String, optional: true
  end
end
