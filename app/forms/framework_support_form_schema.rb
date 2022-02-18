#
# Validate "find-a-framework support requests"
#
# @abstract Form Object for multi-step Find-a-Framework support questionnaire
#
#   1: dsi                    (skipped if logged in)
#   2: group                  (skipped if inferred at login)
#   3: school_urn             (skipped if inferred at login)
#   3: group_uid              (skipped if inferred at login)
#   4: correct_group          (guest only)
#   4: correct_organisation   (guest only)
#   5: first_nane             (guest only)
#   5: last_name              (guest only)
#   6: email                  (guest only)
#   7: message_body           (last and compulsory)
#
class FrameworkSupportFormSchema < Schema
  config.messages.top_namespace = :framework_request

  params do
    optional(:dsi).value(:bool)
    optional(:group).value(:bool)
    optional(:school_urn).value(:string)
    optional(:group_uid).value(:string)
    optional(:correct_organisation).value(:bool)
    optional(:correct_group).value(:bool)
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

  rule do
    # validate that an organisation from an authenticated user's approved list is selected
    # either urn for a school or uid for a group
    base.failure(:affiliation) if values[:dsi].present? && values[:school_urn].blank? && values[:group_uid].blank?
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
