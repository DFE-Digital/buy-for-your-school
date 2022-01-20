#
# Base form object
#
class Form
  extend Dry::Initializer

  # @!attribute [r] messages
  #   @return [Hash] field validation error messages
  option :messages, Types::Hash, default: proc { {} }

  # @!attribute [r] step
  # @return [Integer] internal counter defaults to 1, coerces strings
  option :step, Types::Params::Integer, default: proc { 1 }

  # Proceed or skip to next questions
  #
  # @param num [Integer] number of steps to advance
  #
  # @return [Integer] next step position
  def advance!(num = 1)
    @step += num
  end

  # Proceed or skip to previous questions
  #
  # @param num [Integer] number of steps to revert
  #
  # @return [Integer] previous step position
  def back!(num = 1)
    @step -= num
  end

  # @return [Hash] form parms as  request attributes
  def to_h
    self.class.dry_initializer.attributes(self).except(:step, :messages)
  end

  # Populate form object with validation messages and form fields from given validation
  #
  # @param [Schema] validation
  #
  # @return [Form]
  def self.from_validation(validation)
    new(messages: validation.errors(full: true).to_h, **validation.to_h)
  end

  # @see https://govuk-form-builder.netlify.app/introduction/error-handling/
  #
  # @return [Form::ErrorSummary]
  def errors
    ErrorSummary.new(messages)
  end

  #
  # Message object for form error handling
  #
  class ErrorSummary
    extend Dry::Initializer

    # @!attribute [r] messages
    #
    # @example
    #   { phone_number: ["size cannot be less than 10"] }
    #
    # @return [Hash]
    param :messages, Types::Hash, default: proc { {} }

    delegate :any?, to: :messages
  end
end
