class CustomerSatisfactionSurveysFlow
  include Rails.application.routes.url_helpers

  def initialize(service_name, current_step = nil)
    @service_name = service_name.to_sym
    @flow = SURVEY_FLOWS[@service_name] || []
    @current_step = current_step || @flow.first
  end

  def current_path
    convert_step_to_path(@current_step)
  end

  def next_path
    following_step = next_step
    following_step ? convert_step_to_path(following_step) : nil
  end

  def back_path
    previous_step = previous_step
    previous_step ? convert_step_to_path(previous_step) : nil
  end

  private

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
end