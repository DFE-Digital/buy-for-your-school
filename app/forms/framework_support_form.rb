# @abstract Form Object for multi-step Find-a-Framework support questionnaire
#
class FrameworkSupportForm < Form
  # @!attribute [r] dsi
  # @return [Boolean]
  option :dsi, Types::Params::Bool | Types.Constructor(::TrueClass, &:present?), optional: true # 1 (skipped if logged in)

  # @!attribute [r] first name
  # @return [String]
  option :first_name, optional: true # 2 (skipped if logged in)

  # @!attribute [r] last name
  # @return [String]
  option :last_name, optional: true # 2 (skipped if logged in)

  # @!attribute [r] email
  # @return [String]
  option :email, optional: true # 3 (skipped if logged in)

  # @!attribute [r] school_urn
  # @return [String]
  option :school_urn, optional: true # 4 (skipped if inferred)

  # @!attribute [r] message_body
  # @see SupportRequest SupportRequest attributes
  # @return [String]
  option :message_body, optional: true # 5 (last and compulsory)

  # @return [Hash] form data to be persisted as request attributes
  def to_h
    instance_variable_set(:@school_urn, school_urn)
    super.except(:dsi)
  end

  # :nocov:
  # @return [Boolean]
  def dsi?
    instance_variable_get :@dsi
  end

  # @return [Boolean]
  def guest?
    !dsi?
  end
  # :nocov:

  # Extract the school URN from the format "urn - name"
  # "100000 - School #1" -> "100000"
  #
  # @return [String, nil]
  def school_urn
    instance_variable_get(:@school_urn).split(" - ").first
  rescue NoMethodError
    nil
  end
end
