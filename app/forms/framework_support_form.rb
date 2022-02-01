# @abstract Form Object for multi-step Find-a-Framework support questionnaire
#
# :nocov:
class FrameworkSupportForm < Form
  # @!attribute [r] dsi
  # @return [Boolean]
  option :dsi, Types::Params::Bool | Types.Constructor(::TrueClass, &:present?), optional: true # 1 (skipped if logged in)

  # @!attribute [r] first_name
  # @return [String]
  option :first_name, optional: true # 2 (skipped if logged in)

  # @!attribute [r] last_name
  # @return [String]
  option :last_name, optional: true # 2 (skipped if logged in)

  # @!attribute [r] email
  # @return [String]
  option :email, optional: true # 3 (skipped if logged in)

  # @!attribute [r] school_urn
  # @return [String] URN identifier and name in the format "100000 - School Name"
  option :school_urn, optional: true # 4 (skipped if inferred at login)

  # @!attribute [r] message_body
  # @see SupportRequest SupportRequest attributes
  # @return [String]
  option :message_body, optional: true # 6 (last and compulsory)

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
end
# :nocov:
