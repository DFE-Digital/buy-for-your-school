require "rails_helper"

RSpec.describe "Analytics event controllers", type: :controller do
  shared_examples "an analytics event controller" do
    let(:user) { instance_double(User, id: 123, dfe_sign_in_uid: "dsi-user-123", guest?: false) }
    let(:sent_events) { [] }

    before do
      controller.define_singleton_method(:current_namespace) { :specify }
      allow(controller).to receive_messages(authenticate_user!: true, current_user: user, feature_flag_event_tags: %w[homepage_rfh_button])
      allow(DfE::Analytics::SendEvents).to receive(:do) { |events| sent_events.concat(events) }
    end

    it "adds tags, the current user and namespace to custom events" do
      post :create, params: {
        event: {
          type: "page_engagement",
          data: { page_path: "/", page_title: "Home" },
        },
      }

      event = sent_events.map(&:as_json).find { |item| item["event_type"].to_s == "page_engagement" }

      expect(event).to include(
        "event_tags" => %w[homepage_rfh_button],
        "user_id" => 123,
        "namespace" => "specify",
      )
    end
  end

  describe DfeAnalyticsEventsController do
    include_examples "an analytics event controller"
  end

  describe EventsController do
    include_examples "an analytics event controller"
  end
end
