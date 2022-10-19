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
class FrameworkSupportForm < RequestForm
  # @!attribute [r] user
  #   @return [UserPresenter] decorate respondent
  option :user, ::Types.Constructor(UserPresenter)

  # @!attribute [r] dsi
  #   @return [Boolean] true if respondent authenticated
  option :dsi, Types::ConfirmationField | Types::Nil, default: proc { true unless user.guest? }

  # @!attribute [r] group
  #   @return [Boolean] requesting support for a group of schools confirmed
  option :group, Types::ConfirmationField | Types::Nil, default: proc { user.group_uid.present? unless user.guest? }

  # @!attribute [r] org_id
  #   @return [String] identifier and name in the format "xxxx - Group/School Name"
  option :org_id, default: proc { user.school_urn || user.group_uid unless user.guest? }

  # @!attribute [r] correct_group
  #   @return [Boolean] selected group confirmed
  option :org_confirm, Types::ConfirmationField, optional: true

  # @!attribute [r] first_name
  #   @return [String]
  option :first_name, default: proc { user.first_name }

  # @!attribute [r] last_name
  #   @return [String]
  option :last_name, default: proc { user.last_name }

  # @!attribute [r] email
  #   @return [String]
  option :email, default: proc { user.email || Dry::Initializer::UNDEFINED }

  # @!attribute [r] message_body
  #   @return [String]
  option :message_body, optional: true

  # @return [Hash] form data to be persisted as request attributes
  def data
    super
      .except(:dsi, :org_confirm)
      .merge(org_id: found_uid_or_urn)
  end

  # Extract school URN or group UID from autocomplete search result
  #
  # @example
  #   "1000 - Name" -> "1000"
  #
  # @return [String, nil]
  def found_uid_or_urn
    org_id&.split(" - ")&.first
  end

  # @return [Hash] Guest "can't find school" tries "search for a group" and vice-versa
  def find_other_type
    to_h
      .except(:user, :messages, :org_id)
      .merge(group: !group, dsi: !user.guest?)
      .reject { |_, v| v.to_s.empty? }
  end

  def school_or_group
    if group
      group = Support::EstablishmentGroup.find_by(uid: found_uid_or_urn)
      @group = Support::EstablishmentGroupPresenter.new(group) if group
    else
      school = Support::Organisation.find_by(urn: found_uid_or_urn)
      @school = Support::OrganisationPresenter.new(school) if school
    end
  end
end
