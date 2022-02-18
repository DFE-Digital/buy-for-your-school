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
  # @!attribute [r] dsi
  # @return [Boolean]
  option :dsi, Types::ConfirmationField, optional: true

  # @!attribute [r] group
  # @return [Boolean]
  option :group, Types::ConfirmationField | Types::Nil, optional: true

  # @!attribute [r] school_urn
  # @return [String] identifier and name in the format "100000 - School Name"
  option :school_urn, optional: true

  # @!attribute [r] group_uid
  # @return [String] identifier and name in the format "1000 - Group Name"
  option :group_uid, optional: true

  # @!attribute [r] correct_group
  # @return [Boolean]
  option :correct_group, Types::ConfirmationField, optional: true

  # @!attribute [r] correct_organisation
  # @return [Boolean]
  option :correct_organisation, Types::ConfirmationField, optional: true

  # @!attribute [r] first_name
  # @return [String]
  option :first_name, optional: true

  # @!attribute [r] last_name
  # @return [String]
  option :last_name, optional: true

  # @!attribute [r] email
  # @return [String]
  option :email, optional: true

  # @!attribute [r] message_body
  # @see SupportRequest SupportRequest attributes
  # @return [String]
  option :message_body, optional: true

  # @return [Hash] form data to be persisted as request attributes
  def to_h
    super.except(:dsi)
  end

  # @return [Boolean]
  def dsi?
    instance_variable_get :@dsi
  end

  # @return [Boolean]
  def guest?
    !dsi?
  end

  # @return [Boolean]
  def multiple_schools?
    instance_variable_get :@group
  end

  # @return [nil]
  def forget_org
    forget_group! if position?(3) && has_school?
    forget_school! if position?(3) && has_group?
  end

private

  # @see FrameworkRequestsController#create
  #
  # @return [Boolean] school URN is present
  def has_school?
    school_urn.present?
  end

  # @see FrameworkRequestsController#create
  #
  # @return [Boolean] group UID is present
  def has_group?
    group_uid.present?
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
