describe Specify::SpecificationsController, type: :controller do
  describe "redirects to the right next steps page based on category" do
    let(:user) { create(:user) }
    let(:journey) { create(:journey, category:, user:) }
    let(:params) { { journey_id: journey.id, form: { finished: true } } }

    before do
      user_is_signed_in(user:)
      post(:create, params:)
    end

    context "when the category is catering" do
      let(:category) { build(:category, :catering) }

      it "redirects to the right next steps page" do
        expect(response).to redirect_to(%r{/next-steps-catering})
      end
    end

    context "when the category is mfd" do
      let(:category) { build(:category, :mfd) }

      it "redirects to the right next steps page" do
        expect(response).to redirect_to(%r{/next-steps-mfd})
      end
    end
  end
end
