class CustomerSatisfactionSurveysFlow
  include Rails.application.routes.url_helpers

  def initialize(service_name, current_step = nil)
    @service_name = service_name&.to_sym
    @flow = SURVEY_FLOWS[@service_name] || []
    @current_step = current_step || @flow.first
  end

  def all_steps
    @flow
  end

  def start_step
    @flow.first
  end

  def current_step
    @current_step
  end

  def next_step
    idx = @flow.index(@current_step)
    return nil unless idx

    # Get the next step from the flow
    @flow[idx + 1]
  end

  def previous_step
    idx = @flow.index(@current_step)
    return nil unless idx && idx > 0

    # Get the previous step from the flow
    @flow[idx - 1]
  end

  def start_path
    convert_step_to_path(start_step)
  end

  def current_path
    convert_step_to_path(@current_step)
  end

  def next_path
    following_step = next_step
    following_step ? convert_step_to_path(following_step) : nil
  end

  def back_path
    prev_step = previous_step
    prev_step ? convert_step_to_path(prev_step) : nil
  end

  def convert_step_to_path(step)
    if step == "thank_you"
      step_path = "customer_satisfaction_surveys_#{step}_path"
    elsif step == "improvement"
      step_path = "edit_customer_satisfaction_surveys_#{step.pluralize}_path"
    else
      step_path = "edit_customer_satisfaction_surveys_#{step}_path"
    end
    step_path
  end

  def get_step_from_path(path)
    if path == "customer_satisfaction_surveys_thank_you_path"
      "thank_you"
    elsif path.include?("edit_customer_satisfaction_surveys_")
      step = path.sub("edit_customer_satisfaction_surveys_", "").sub("_path", "")
      step == "improvements" ? "improvement" : step
    else
      nil
    end
  end
end