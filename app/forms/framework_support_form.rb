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
class FrameworkSupportForm < Form
  # @!attribute [r] user
  #   @return [UserPresenter] decorate respondent
  option :user, ::Types.Constructor(UserPresenter)

  # @!attribute [r] step
  #   @return [Integer]
  option :step, Types::Params::Integer, default: proc {
    if user.guest?
      1
    else
      user.single_org? ? 7 : 3
    end
  }

  # @!attribute [r] dsi
  #   @return [Boolean] true if respondent authenticated
  option :dsi, Types::ConfirmationField | Types::Nil, default: proc { true unless user.guest? }

  # @!attribute [r] group
  #   @return [Boolean] requesting support for a group of schools confirmed
  option :group, Types::ConfirmationField | Types::Nil, default: proc { user.group_uid.present? unless user.guest? }

  # @!attribute [r] school_urn
  #   @return [String] identifier and name in the format "100000 - School Name"
  option :school_urn, default: proc { user.school_urn unless user.guest? }

  # @!attribute [r] group_uid
  #   @return [String] identifier and name in the format "1000 - Group Name"
  option :group_uid, default: proc { user.group_uid unless user.guest? }

  # @!attribute [r] correct_group
  #   @return [Boolean] selected group confirmed
  option :correct_group, Types::ConfirmationField, optional: true

  # @!attribute [r] correct_organisation
  #   @return [Boolean] selected school confirmed
  option :correct_organisation, Types::ConfirmationField, optional: true

  # @!attribute [r] first_name
  #   @return [String]
  option :first_name, default: proc { user.first_name }

  # @!attribute [r] last_name
  #   @return [String]
  option :last_name, default: proc { user.last_name }

  # @!attribute [r] email
  #   @return [String]
  option :email, default: proc { user.email }

  # @!attribute [r] message_body
  #   @return [String]
  option :message_body, optional: true

  # @return [Hash] form data to be persisted as request attributes
  def data
    to_h
      .except(:user, :step, :messages, :dsi, :correct_group, :correct_organisation)
      .compact
      .merge(user_id: user.id, school_urn: urn, group_uid: uid, group: uid.present?)
  end

  # Prevent validation errors being raised for empty fields
  #
  # @return [Hash] toggle form data to step backward
  def go_back
    to_h.except(:user, :messages).merge(back: true, group: group.to_s).reject { |_, v| v.blank? }
  end

  # @return [Hash] toggle form data to include "Search for a school"
  def find_school
    advance!
    go_back.merge(group: false)
  end

  # @return [Hash] toggle form data to include "Search for a group"
  def find_group
    advance!
    go_back.merge(group: true)
  end

  # @return [Boolean]
  def restart?
    (position?(7) && login_with_inferred_org?) || (position?(3) && login_with_many_orgs?)
  end

  # @return [Boolean]
  def reselect?
    if user.guest? && position?(4)
      affiliation_unconfirmed?
    end
  end

  # @return [Boolean]
  def confirmation_required?
    if guest_selecting_org?
      group_uid.present? && correct_group.nil? || school_urn.present? && correct_organisation.nil?
    end
  end

  # Conditional jumps to different steps or incremental move forward
  #
  # @return [Integer]
  def forward
    if guest_selecting_org?
      group ? forget_school! : forget_group!
    end

    if position?(3) && login_with_many_orgs?
      go_to!(7)
    else
      advance!
    end
  end

  # Conditional jumps to different steps or incremental move backward
  #
  # @return [Integer]
  def backward
    if position?(7) && login_with_many_orgs?
      go_to!(3)

    # This breaks the expected convention of going to the previous page but can
    # be used to skip over the "confirm school/group details" page.
    #
    # @see https://design-system.service.gov.uk/components/back-link/
    #
    # elsif position?(5)
    #   go_to!(3)
    else
      back!
    end
  end

  # Extract the school URN from the format "urn - school name"
  #
  # @example
  #   "100000 - School #1" -> "100000"
  #
  # @return [String, nil]
  def urn
    school_urn&.split(" - ")&.first unless group
  end

  # Extract the group UID from the format "uid - group name"
  #
  # @example
  #   "1000 - Group #1" -> "1000"
  #
  # @return [String, nil]
  def uid
    group_uid&.split(" - ")&.first if group
  end

private

  # @return [Boolean]
  def guest_selecting_org?
    user.guest? && (position?(2) || position?(3))
  end

  # @return [Boolean]
  def affiliation_unconfirmed?
    correct_group.eql?(false) || correct_organisation.eql?(false)
  end

  # @return [Boolean]
  def login_with_many_orgs?
    !user.guest? && !user.single_org?
  end

  # @return [Boolean]
  def login_with_inferred_org?
    !user.guest? && user.single_org?
  end

  # @return [nil]
  def forget_school!
    instance_variable_set :@school_urn, nil
  end

  # @return [nil]
  def forget_group!
    instance_variable_set :@group_uid, nil
  end
end
