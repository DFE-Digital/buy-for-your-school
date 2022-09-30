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

  # Prevent validation errors being raised for empty fields
  #
  # @return [Hash] toggle form data to step backward
  def go_back
    to_h
      .except(:user, :messages)
      .merge(back: true, group:, dsi: !user.guest?)
      .reject { |_, v| v.to_s.empty? }
  end

  # Conditional jumps to different steps or incremental move forward
  #
  # @return [Integer] new step position
  def forward
    if position?(3) && dsi_with_many_orgs?
      go_to!(7)
    else
      advance!
    end
  end

  # Conditional jumps to different steps or incremental move backward
  #
  # @return [Integer] new step position
  def backward
    if position?(7) && dsi_with_many_orgs?
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

  # Guest Users ----------------------------------------------------------------

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
    advance!
    go_back.except(:org_id).merge(group: !group)
  end

  # Guest answered "no" to "is this the correct school/group?"
  #
  # @return [Boolean]
  def reselect?
    if user.guest? && position?(4)
      org_confirm.eql?(false)
    else
      false
    end
  end

  # @see FrameworkRequestController#update
  #
  def next?
    if user.guest? && position?(2)
      true # group choice
    elsif user.guest? && position?(3)
      org_id.present? # org selected
    else
      false
    end
  end

  # DSI Users ----------------------------------------------------------------

  # @return [Boolean]
  def restart?
    position?(7) && dsi_with_inferred_org? || position?(3) && dsi_with_many_orgs?
  end

private

  # @return [Boolean]
  def dsi_selecting_org?
    !user.guest? && position?(3)
  end

  # @return [Boolean]
  def dsi_with_many_orgs?
    !user.guest? && !user.single_org?
  end

  # @return [Boolean]
  def dsi_with_inferred_org?
    !user.guest? && user.single_org?
  end
end
