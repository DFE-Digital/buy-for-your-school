module Support
  class CaseEmailContentForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    option :email_template, Types::Params::String, optional: true, default: proc { EmailTemplates::IDS[:basic_template] }
    option :email_subject, Types::Params::String, optional: true
    option :email_body, Types::Params::String, optional: true
    option :text, Types::Params::String
  end
end
