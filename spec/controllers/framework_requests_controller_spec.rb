require "rails_helper"

describe FrameworkRequestsController do
  describe "index" do
    context "when referred_by parameter is given" do
      it "sets the referral url in the session" do
        get :index, params: { referred_by: Base64.encode64("https://www.google.com") }
        expect(session[:faf_referrer]).to eq("https://www.google.com")
      end
    end

    context "when request has a referrer" do
      it "sets the referral url in the session" do
        request.env["HTTP_REFERER"] = "https://www.google.com"
        get :index
        expect(session[:faf_referrer]).to eq("https://www.google.com")
      end
    end

    it "sets the referral url to direct" do
      get :index
      expect(session[:faf_referrer]).to eq("direct")
    end
  end
end
