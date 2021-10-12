class Navigators::BasicNavigator
  attr_reader :first_step, :last_step

  def initialize(first_step: 1, last_step: 99)
    @first_step = first_step
    @last_step = last_step
  end

  def steps_forward(_form)
    1
  end

  def steps_backwards(_form)
    1
  end
end
