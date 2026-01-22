class EventsController < ApplicationController
  EVENT_ALLOWLIST = {
    external_link_clicked: %i[text href],
    page_engagement: %i[engaged_time_ms page_path page_title session_duration_ms timestamp],
  }.freeze

  def create
    type = event_params[:type]&.to_sym
    return bad_request unless EVENT_ALLOWLIST.key?(type)

    data = event_params[:data].to_h.slice(*EVENT_ALLOWLIST[type])
    send_dfe_analytics_event(type, data)

    head :no_content
  end

private

  def event_params
    params.require(:event).permit(:type, data: {})
  end

  def bad_request
    head(:bad_request)
  end

  def send_dfe_analytics_event(type, data)
    event = DfE::Analytics::Event.new
      .with_type(type)
      .with_request_details(request)
      .with_response_details(response)
      .with_data(data:)

    DfE::Analytics::SendEvents.do([event])
  end
end
