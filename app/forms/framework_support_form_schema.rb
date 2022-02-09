#
# Validate "find-a-framework support requests"
#
# :nocov:
class FrameworkSupportFormSchema < Schema
  config.messages.top_namespace = :framework_request

  params do
    optional(:dsi).value(:bool)                 # step 1

    optional(:group).value(:bool)               # step 2

    optional(:first_name).value(:string)        # step 3
    optional(:last_name).value(:string)         # step 3

    optional(:school_urn).value(:string)        # step 4
             
    optional(:email).value(:string)             # step 4

    optional(:school_urn).value(:string)        # step 5

    optional(:group_uid).value(:string)         # step 5

    optional(:message_body).value(:string)      # step 7
  end

  rule(:first_name) do
    key.failure(:missing) if key? && value.blank?
  end

  rule(:last_name) do
    key.failure(:missing) if key? && value.blank?
  end

  rule(:email) do
    if key? && (value.blank? || !URI::MailTo::EMAIL_REGEXP.match?(value))
      key.failure(:missing)
    end
  end

  rule(:school_urn) do
    key.failure(:missing) if key? && !values[:group] && Support::Organisation.find_by(urn: value.split(" - ").first).nil?
  end

  rule(:group_uid) do
    key.failure(:missing) if key? && values[:group] && Support::EstablishmentGroup.find_by(uid: value.split(" - ").first).nil?
  end

  rule(:message_body) do
    key.failure(:missing) if key? && value.blank?
  end
end
# :nocov:
