require "rails_helper"

describe "Request for support: user journey tracking" do
  context "when the session_id parameter is provided" do
    context "and a user journey exists for this session id" do
      before { create(:user_journey, session_id: "SESSION-ID") }

      it "records the step against the existing journey" do
        get "/procurement-support?session_id=SESSION-ID"
        expect(UserJourney.where(session_id: "SESSION-ID").count).to eq(1)
        expect(UserJourney.find_by(session_id: "SESSION-ID").user_journey_steps.last.step_description).to eq("/procurement-support")
      end
    end

    context "and a user journey does not exist for this session id" do
      it "records the step against a new in progress journey" do
        get "/procurement-support?session_id=SESSION-ID"
        expect(UserJourney.where(session_id: "SESSION-ID").count).to eq(1)
        expect(UserJourney.find_by(session_id: "SESSION-ID").user_journey_steps.last.step_description).to eq("/procurement-support")
      end
    end
  end

  context "when the referral_campaign parameter is provided" do
    it "saves the referral against the new user journey" do
      get "/procurement-support?referral_campaign=marketing"
      expect(UserJourney.first.referral_campaign).to eq("marketing")
    end
  end

  context "when the request is a bot" do
    it "does not track user" do
      get "/procurement-support", headers: { "HTTP_USER_AGENT" => "bot" }
      expect(UserJourney.count).to eq(0)
    end
  end
end
