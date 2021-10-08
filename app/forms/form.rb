require "types"
require "dry-initializer"

# @abstract Form Object for multi-step questionnaires
#
# @author Peter Hamilton
#
class Form
  extend Dry::Initializer

  # @see https://design-system.service.gov.uk/components/error-summary/
  #
  class ErrorSummary
    extend Dry::Initializer

    # @example
    #
    #   { phone_number: ["size cannot be less than 10"] }
    #
    param :messages, Types::Hash, default: proc { {} }

    delegate :any?, to: :messages
  end

  # internal counter defaults to 1, coerces strings
  option :step, Types::Params::Integer, default: proc { 1 }

  # field validation error messages
  option :messages, Types::Hash, default: proc { {} }

  # @see https://govuk-form-builder.netlify.app/introduction/error-handling/
  #
  # @return [ErrorSummary]
  def errors
    ErrorSummary.new(messages)
  end

  # Proceed to next question
  #
  # @return [Integer] next step position
  def advance!
    @step += 1
  end

  # Miss a question
  #
  # @return [Integer] next step position
  def skip!
    @step += 2
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
