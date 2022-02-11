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

    optional(:choice).value(:bool)
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
    # validate individual school_urn field only in the non-dsi journey
    key.failure(:missing) if key? && !values[:dsi] && !values[:group] && !org_exists?(value.split(" - ").first, false)
  end

  rule(:group_uid) do
    # validate individual group_uid field only in the non-dsi journey
    key.failure(:missing) if key? && !values[:dsi] && values[:group] && !org_exists?(value.split(" - ").first, true)
  end

  rule(:message_body) do
    key.failure(:missing) if key? && value.blank?
  end

  rule do
    # validate that either school_urn or group_uid is provided in the dsi journey
    base.failure(:missing_org) if values[:dsi] && values[:school_urn].blank? && values[:group_uid].blank?
  end

  def org_exists?(id, group)
    if group
      Support::EstablishmentGroup.find_by(uid: id).present?
    else
      Support::Organisation.find_by(urn: id).present?
    end
  end
end
# :nocov:
