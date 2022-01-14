# @abstract Form Object for multi-step Find-a-Framework support questionnaire
#
class FafForm
  extend Dry::Initializer

  # @see https://design-system.service.gov.uk/components/error-summary/
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

  # @!attribute [r] step
  # @return [Integer] internal counter defaults to 1, coerces strings
  option :step, Types::Params::Integer, default: proc { 1 }

  # @!attribute [r] messages
  # @return [Hash] field validation error messages
  option :messages, Types::Hash, default: proc { {} }

  # @!attribute [r] dsi
  # @return [Boolean]
  option :dsi, Types::Params::Bool, optional: true # 1

  # @see https://govuk-form-builder.netlify.app/introduction/error-handling/
  #
  # @return [ErrorSummary]
  def errors
    ErrorSummary.new(messages)
  end

  # Proceed or skip to next questions
  #
  # @param num [Integer] number of steps to advance
  #
  # @return [Integer] next step position
  def advance!(num = 1)
    @step += num
  end

  # @return [Integer] previous step position
  def back
    @step - 1
  end

  # @see SupportRequestsController#update
  #
  # @return [Hash] form parms as support request attributes
  def to_h
    self.class.dry_initializer.attributes(self).except(:step, :messages)
  end
end
