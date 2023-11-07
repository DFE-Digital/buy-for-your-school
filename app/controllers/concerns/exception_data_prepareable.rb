module ExceptionDataPrepareable
  extend ActiveSupport::Concern

  included do
    before_action :prepare_exception_notifier
  end

private

  def prepare_exception_notifier
    request.env["exception_notifier.exception_data"] = exception_notifier_data
  end

  def exception_notifier_data
    data = {}
    data[:request_id] = request.request_id
    data[:app_insights_request_id] = request.env["ApplicationInsights.request.id"]
    data[:current_user] = current_user.id if current_user.present?
    data[:current_agent] = current_agent.id if defined?(current_agent) && current_agent.present?
    data[:url] = request.original_url
    data[:controller] = controller_name
    data[:action] = action_name
    data
  end
end
