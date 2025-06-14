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

  attr_reader :current_step

  def next_step
    idx = @flow.index(@current_step)
    return nil unless idx

    # Get the next step from the flow
    @flow[idx + 1]
  end

  def previous_step
    idx = @flow.index(@current_step)
    return nil unless idx && idx.positive?

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
    case step
    when "thank_you"
      "customer_satisfaction_surveys_thank_you_path"
    when "improvement"
      "edit_customer_satisfaction_surveys_improvements_path"
    else
      "edit_customer_satisfaction_surveys_#{step}_path"
    end
  end

  def get_step_from_path(path)
    return nil if path.nil?

    path.gsub(/\A(edit_)?customer_satisfaction_surveys_|_path\z/, "")
        .singularize
  end
end
