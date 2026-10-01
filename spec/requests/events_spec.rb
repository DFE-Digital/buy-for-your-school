require "rails_helper"

RSpec.describe "Tracking events", type: :request do
  let(:sent_events) { [] }

  before do
    allow(DfE::Analytics::SendEvents).to receive(:do) do |events|
      sent_events.concat(events)
    end
  end

  describe "POST /events" do
    {
      external_link_clicked: { text: "External link", href: "https://example.com" },
      internal_link_clicked: { text: "Internal link", href: "/categories/catering" },
      page_engagement: {
        engaged_time_ms: 10_000,
        page_path: "/categories/catering",
        page_title: "Catering",
        session_duration_ms: 12_000,
        timestamp: "2026-09-25T14:00:00Z",
      },
    }.each do |type, data|
      it "forwards the #{type} event to DfE Analytics" do
        post "/events",
             params: { event: { type:, data: data.merge(unexpected: "ignored") } }.to_json,
             headers: { "Content-Type" => "application/json", "Accept" => "*/*" }

        expect(response).to have_http_status(:no_content)

        event = sent_events.map { |sent_event| sent_event.as_json.with_indifferent_access }
          .find { |sent_event| sent_event[:event_type].to_s == type.to_s }
        expect(event).to be_present
        expect(event[:data].map { |field| field["key"] }).to match_array(data.keys.map(&:to_s))
      end
    end

    it "rejects event types that are not in the tracking allowlist" do
      post "/events",
           params: { event: { type: "unsupported_event", data: {} } }.to_json,
           headers: { "Content-Type" => "application/json", "Accept" => "*/*" }

      expect(response).to have_http_status(:bad_request)
      expect(sent_events.map { |event| event.as_json.with_indifferent_access[:event_type].to_s })
        .not_to include("unsupported_event")
    end
  end
end
