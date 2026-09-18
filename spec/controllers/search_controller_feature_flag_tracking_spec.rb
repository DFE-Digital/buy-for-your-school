RSpec.describe SearchController, type: :controller do
  let(:user) { instance_double(User, id: 123, dfe_sign_in_uid: "dsi-user-123", guest?: false) }
  let(:sent_events) { [] }

  before do
    controller.define_singleton_method(:current_namespace) { :specify }
    allow(controller).to receive_messages(current_user: user, path_excluded?: false, feature_flag_event_tags: %w[homepage_rfh_button])
    allow(DfE::Analytics).to receive(:enabled?).and_return(true)
    allow(DfE::Analytics::SendEvents).to receive(:do) { |events| sent_events.concat(events) }
  end

  describe "feature flag actors" do
    it "uses the signed-in user's DfE Sign-in UID" do
      allow(controller).to receive(:current_user).and_return(user)
      allow(Flipper).to receive(:enabled?).and_return(true)

      expect(controller.ab_test_enabled?(:homepage_rfh_button)).to be(true)
      expect(Flipper).to have_received(:enabled?).with(
        :homepage_rfh_button,
        satisfy { |actor| actor.flipper_id == "user:dsi-user-123" },
      )
    end

    it "stores one anonymous actor ID in the session" do
      guest = instance_double(Guest, guest?: true)
      allow(controller).to receive(:current_user).and_return(guest)
      allow(Flipper).to receive(:enabled?).and_return(true)
      allow(SecureRandom).to receive(:uuid).and_return("anonymous-id")

      2.times { controller.ab_test_enabled?(:homepage_rfh_button) }

      expect(controller.session[:feature_flag_actor_id]).to eq("anonymous-id")
    end

    it "returns only enabled experiment flags as analytics tags" do
      allow(controller).to receive(:current_user).and_return(user)
      allow(Flipper).to receive(:enabled?).with(:homepage_rfh_button, anything).and_return(true)

      expect(controller.feature_flag_event_tags).to eq(%w[homepage_rfh_button])
    end
  end

  it "adds tags, the current user and namespace to page impression events" do
    expect(controller).to receive(:trigger_request_event).with("web_request").and_call_original

    get :index, params: { query: "" }
    expect(controller.request.path).to eq(search_path)
    event = sent_events.map(&:as_json).last

    expect(event).to include(
      "event_tags" => %w[homepage_rfh_button],
      "user_id" => 123,
      "namespace" => "specify",
    )
  end
end
