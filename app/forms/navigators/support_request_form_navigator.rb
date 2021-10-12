class Navigators::SupportRequestFormNavigator
  attr_reader :first_step, :last_step, :user_journeys

  def initialize(first_step: 1, last_step: 4, user_journeys: [])
    @first_step = first_step
    @last_step = last_step
    @user_journeys = user_journeys
  end

  def steps_forward(form)
    case form.step
    when 1 then user_journeys.none? ? 2 : 1
    when 2 then form.has_journey? ? 2 : 1
    else
      1
    end
  end

  def steps_backwards(form)
    case form.step
    when 3 then user_journeys.none? ? 2 : 1
    when 4 then form.has_journey? ? 2 : 1
    else
      1
    end
  end
end
