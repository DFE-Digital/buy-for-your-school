module Support
  class CaseEmailContentForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    # @!attribute [r] email_template
    #   @return [String] default "basic" template
    option :email_template, Types::Params::String, default: proc { "ac679471-8bb9-4364-a534-e87f585c46f3" }

    # @!attribute [r] email_subject
    #   @return [String]
    option :email_subject, Types::Params::String, optional: true

    # @!attribute [r] email_body
    #   @return [String]
    option :email_body, Types::Params::String, optional: true
  end
end
