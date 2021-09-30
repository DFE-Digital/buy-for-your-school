require "rails_helper"

RSpec.describe "Authorisation", type: :request do
  describe "Users can only see journeys they belong to" do
    context "when the journey IS theirs" do
      it "returns 200" do
        journey = create(:journey)
        user_is_signed_in(user: journey.user)

        get journey_path(journey)

        expect(response).to have_http_status(:ok)
      end
    end

    context "when the journey is NOT theirs" do
      it "returns 404" do
        another_user = build(:user)
        journey = create(:journey)
        user_is_signed_in(user: another_user)

        get journey_path(journey)

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
