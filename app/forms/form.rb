#
# Base form object
#
class Form
  extend Dry::Initializer
  # extend Dry::Initializer[undefined: false]

  # @!attribute [r] user
  #   @return [?] form respondent, overridden in subclassed forms
  option :user, optional: true, reader: :private

  # @!attribute [r] messages
  #   @return [Hash] field validation error messages
  option :messages, Types::Hash, default: proc { {} }

  # @!attribute [r] step
  # @return [Integer] internal counter defaults to 1, coerces strings
  option :step, Types::Params::Integer, default: proc { 1 }

  # @param position [Integer] number of steps to advance
  #
  # @return [Boolean] assert step position
  def position?(position)
    @step == position
  end

  # Jump to specific step
  #
  # @param position [Integer] step number
  #
  # @return [Integer] step number
  def go_to!(position)
    @step = position
  end

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

  # Override and prune keys that will not be persisted
  #  super.except(:user, :step, :messages)
  #
  # @return [Hash] overridden form params as request attributes
  def to_h
    self.class.dry_initializer.attributes(self)
  end

  # @return [Hash] form params as request attributes
  def data
    to_h.except(:user, :step, :messages).merge(user_id: user.id)
  end

  # FIXME
  # @return [Hash] form params as request attributes
  # def back_data
  #   data.except(:messages).merge(back: true).compact
  # end

  # @see https://govuk-form-builder.netlify.app/introduction/error-handling/
  #
  # @return [Form::ErrorSummary]
  def errors
    ErrorSummary.new(messages)
  end

  # Conditional jumps to different steps or incremental move forward
  #
  # @return [Integer]
  def forward
    # noop
  end

  # Conditional jumps to different steps or incremental move backward
  #
  # @return [Integer]
  def backward
    # noop
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
