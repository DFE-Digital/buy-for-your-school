# @abstract Form Object for multi-step Find-a-Framework support questionnaire
#
# :nocov:
class FrameworkSupportForm < Form
  # @!attribute [r] dsi
  # @return [Boolean]
  option :dsi, Types::Params::Bool | Types.Constructor(::TrueClass, &:present?), optional: true # 1 (skipped if logged in)

  # @!attribute [r] group
  # @return [Boolean]
  option :group, Types::Params::Bool | Types.Constructor(::TrueClass, &:present?), optional: true # 2 (skipped if logged in)

  # @!attribute [r] first_name
  # @return [String]
  option :first_name, optional: true # 3 (skipped if logged in)

  # @!attribute [r] last_name
  # @return [String]
  option :last_name, optional: true # 3 (skipped if logged in)

  # @!attribute [r] email
  # @return [String]
  option :email, optional: true # 4 (skipped if logged in)

  option :group, optional: true

  # @!attribute [r] school_urn
  # @return [String] URN identifier and name in the format "100000 - School Name"
  option :school_urn, optional: true # 5 (skipped if inferred at login)

  # @!attribute [r] group_uid
  # @return [String] identifier and name in the format "1000 - Group Name"
  option :group_uid, optional: true # 4 (non-DSI only)

  # @!attribute [r] message_body
  # @see SupportRequest SupportRequest attributes
  # @return [String]
  option :message_body, optional: true # 7 (last and compulsory)

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
# :nocov:
