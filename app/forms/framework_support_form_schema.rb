#
# Validate "find-a-framework support requests"
#
# @abstract Form Object for multi-step Find-a-Framework support questionnaire
#
#   1: dsi            (skipped if logged in)
#   2: group          (skipped if inferred at login)
#   3: org_id         (guest > autocomplete / dsi skipped if inferred at login)
#   4: org_confirm    (guest only)
#   5: first_nane     (guest only)
#   5: last_name      (guest only)
#   6: email          (guest only)
#   7: message_body   (last and compulsory)
#
class FrameworkSupportFormSchema < Schema
  config.messages.top_namespace = :framework_request

  params do
    optional(:step).value(:integer)
    optional(:dsi).value(:bool)
    optional(:group).value(:bool)
    optional(:org_id).value(:string)
    optional(:org_confirm).value(:string)
    optional(:first_name).value(:string)
    optional(:last_name).value(:string)
    optional(:email).value(:string)
    optional(:message_body).value(:string)
  end

  rule(:first_name) do
    key.failure(:missing) if key? && value.blank?
  end

  rule(:last_name) do
    key.failure(:missing) if key? && value.blank?
  end

  rule(:email) do
    # FIXME: "a@a" without a dot suffix passes validation
    if key? && (value.blank? || !URI::MailTo::EMAIL_REGEXP.match?(value))
      key.failure(:missing)
    end
  end

  rule(:org_id) do
    # Guest forms enter autocompleted schools/groups, ensure organisation exists
    if key? && !values[:dsi]
      not_found = !find_org(value.split(" - ").first, values[:group])

      key.failure(:group) if not_found && values[:group]
      key.failure(:school) if not_found && !values[:group]
    end
  end

  rule(:org_confirm) do
    key.failure(:group) if key? && value.blank? && !values[:dsi] && values[:group]
    key.failure(:school) if key? && value.blank? && !values[:dsi] && !values[:group]
  end

  rule(:message_body) do
    key.failure(:missing) if key? && value.blank?
  end

  rule do
    base.failure(:affiliation) if values[:dsi].present? && values[:org_id].blank?
  end

  # TODO: extract into a look-up service rather than access supported data directly
  # @param id [String] school urn or group uid
  # @param group [Boolean]
  #
  # @return [Boolean]
  def find_org(id, group)
    if group
      Support::EstablishmentGroup.find_by(uid: id).present?
    else
      Support::Organisation.find_by(urn: id).present?
    end
  end
end
