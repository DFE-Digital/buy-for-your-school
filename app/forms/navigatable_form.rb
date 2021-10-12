require "types"
require "dry-initializer"

module NavigatableForm
  extend ActiveSupport::Concern

  included do
    # internal counter defaults to 1, coerces strings
    option :step, Types::Params::Integer, default: proc { 1 }

    # track which direction the user is travelling through the form
    option :direction, Types::Params::Symbol, optional: true, default: proc { :forwards }
    option :navigator, optional: true, default: proc { Navigators::BasicNavigator.new }
  end

  # Proceed forwards or backwards through the form steps
  #
  # @return [nil]
  def navigate
    if direction == :forwards
      move_forwards!(navigator.steps_forward(self))
    else
      move_backwards!(navigator.steps_backwards(self))
    end
  end

  # Proceed directly to next question not exceeding last step
  #
  # @param [Integer] number_of_steps number of steps to move forwards (default 1)
  #
  # @return [Integer] next step position
  def move_forwards!(number_of_steps = 1)
    @step += number_of_steps
    @step = [@step, navigator.last_step].min
    @step
  end

  # Proceed directly to previous question not preceding first step
  #
  # @param [Integer] number_of_steps number of steps to move backwards (default 1)
  #
  # @return [Integer] next step position
  def move_backwards!(number_of_steps = 1)
    @step -= number_of_steps
    @step = [@step, navigator.first_step].max
    @step
  end
end
