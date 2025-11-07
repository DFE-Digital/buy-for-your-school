describe Referrals::ReferralsController, type: :controller do
  let(:params) { { referral_path: "govuk-guidance" } }

  describe "rfh" do
    it "redirects to /procurement_support" do
      get(:rfh, params:)
      expect(response).to redirect_to framework_requests_path
    end
  end

  describe "faf" do
    context "when in production" do
      before { allow(Rails.env).to receive(:production?).and_return(true) }

      it "redirects to FaF production" do
        get(:faf, params:)
        expect(response).to redirect_to %r{https://find-dfe-approved-framework\.service\.gov\.uk/\?sessionId=}
      end
    end

    context "when not in production" do
      it "redirects to FaF test" do
        get(:faf, params:)
        expect(response).to redirect_to %r{https://s107t01-webapp-v2-01\.azurewebsites\.net/\?sessionId=}
      end
    end
  end
end
