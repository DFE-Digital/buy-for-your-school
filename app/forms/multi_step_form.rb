# @abstract Form Object for multi-step questionnaires
#
# @author Peter Hamilton
#
class MultiStepForm
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

  # field validation error messages
  option :messages, Types::Hash, default: proc { {} }

  # internal counter defaults to 1, coerces strings
  option :step, Types::Params::Integer, default: proc { 1 }

  # define how many steps a form has, used to ensure form navigation not overrun.
  # should be overridden by inheriting forms.
  option :total_steps, optional: true, default: proc { 99 }

  # track which direction the user is travelling through the form
  option :direction, Types::Params::Symbol, optional: true, default: proc { :forwards }

  # @see https://govuk-form-builder.netlify.app/introduction/error-handling/
  #
  # @return [ErrorSummary]
  def errors
    ErrorSummary.new(messages)
  end

  # Proceed forwards or backwards through the form steps
  #
  # @return [nil]
  def navigate
    if direction == :forwards
      move_forwards!(steps_to_move_forwards)
    else
      move_backwards!(steps_to_move_backwards)
    end
  end

  # Calculate the next valid step when navigating forwards not exceeding last step
  #
  # @param [Integer] number_of_steps number of steps to move forwards (default is 1)
  #
  # @return [Integer] next step position
  def move_forwards(number_of_steps = 1)
    next_step = step + number_of_steps
    [next_step, total_steps].min
  end

  # Proceed directly to next question
  #
  # @param [Integer] number_of_steps number of steps to move forwards (default is 1)
  #
  # @return [Integer] next step position
  def move_forwards!(number_of_steps = 1)
    @step = move_forwards(number_of_steps)
  end

  # Calculate the next valid step when navigating backwards not exceeding last step
  #
  # @param [Integer] number_of_steps number of steps to move backwards (default is 1)
  #
  # @return [Integer] next step position
  def move_backwards(number_of_steps = 1)
    next_step = step - number_of_steps
    [next_step, 1].max
  end

  # Proceed directly to previous question not preceding first step
  #
  # @param [Integer] number_of_steps number of steps to move backwards (default is 1)
  #
  # @return [Integer] next step position
  def move_backwards!(number_of_steps = 1)
    @step = move_backwards(number_of_steps)
  end

  # Calculate how many steps to progress forwards based on current step.
  # Intended to be overriden by different forms.
  #
  # @return [Integer] number of steps to navigate backwards
  def steps_to_move_forwards
    1
  end

  # Calculate how many steps to progress backwards based on current step.
  # Intended to be overriden by different forms.
  #
  # @return [Integer] number of steps to navigate backwards
  def steps_to_move_backwards
    1
  end

  # @see SupportRequestsController#update
  #
  # @return [Hash] form parms as support request attributes
  def to_h
    self.class.dry_initializer.attributes(self).except(
      :messages,
      :direction,
      :step,
      :navigator,
      :user_journeys,
      :total_steps,
    )
  end
end
