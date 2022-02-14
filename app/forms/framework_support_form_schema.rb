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

    optional(:correct_organisation).value(:bool) # step 6

    optional(:correct_group).value(:bool) # step 6

    optional(:affiliation).value(:string)
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
    key.failure(:missing) if key? && !values[:dsi] && !values[:group] && !org_exists?(value, :school)
  end

  rule(:group_uid) do
    # validate individual group_uid field only in the non-dsi journey
    key.failure(:missing) if key? && !values[:dsi] && values[:group] && !org_exists?(value, :group)
  end

  rule(:message_body) do
    key.failure(:missing) if key? && value.blank?
  end

  rule(:affiliation) do
    # validate that either school_urn or group_uid is provided in the dsi journey
    key.failure(:missing) if values[:dsi] && values[:school_urn].blank? && values[:group_uid].blank?
  end

  # TODO: extract into a look-up service rather than access supported data directly
  #
  # @param [String] id - organisation ID in the format "uid - name"
  # @param [Symbol] type - :school or :group
  #
  # @return [Boolean]
  def org_exists?(id, type)
    id = id.split(" - ").first

    case type
    when :school
      Support::Organisation.find_by(urn: id).present?
    when :group
      Support::EstablishmentGroup.find_by(uid: id).present?
    end
  end
end
# :nocov:
