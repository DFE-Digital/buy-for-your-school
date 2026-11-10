require "rails_helper"

describe PagesController do
  describe "show" do
    context "when the page is the request for help start page" do
      let(:start_page) do
        OpenStruct.new(title: "Request help", slug: "procurement-support", parent: nil)
      end

      before do
        allow(FABS::Page).to receive(:find_by_slug!).with("procurement-support").and_return(start_page)
      end

      context "when referred_by parameter is given" do
        it "sets the referral url in the session" do
          get :show, params: { slug: "procurement-support", referred_by: Base64.encode64("https://www.google.com") }
          expect(session[:faf_referrer]).to eq("https://www.google.com")
        end
      end

      context "when request has a referrer" do
        it "sets the referral url in the session" do
          request.env["HTTP_REFERER"] = "https://www.google.com"
          get :show, params: { slug: "procurement-support" }
          expect(session[:faf_referrer]).to eq("https://www.google.com")
        end
      end

      it "sets the referral url to direct" do
        get :show, params: { slug: "procurement-support" }
        expect(session[:faf_referrer]).to eq("direct")
      end

      it "clears the energy onboarding session" do
        session[:energy_onboarding] = true
        session[:energy_case_tasks_path] = "/energy/case/tasks"

        get :show, params: { slug: "procurement-support" }

        expect(session[:energy_onboarding]).to be_nil
        expect(session[:energy_case_tasks_path]).to be_nil
      end
    end

    context "when the page is not the request for help start page" do
      let(:other_page) do
        OpenStruct.new(title: "Other page", slug: "other-page", parent: nil)
      end

      before do
        allow(FABS::Page).to receive(:find_by_slug!).with("other-page").and_return(other_page)
      end

      it "does not set the referral url in the session" do
        get :show, params: { slug: "other-page" }
        expect(session[:faf_referrer]).to be_nil
      end
    end
  end
end
