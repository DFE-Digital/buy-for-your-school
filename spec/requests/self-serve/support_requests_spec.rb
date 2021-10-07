require "rails_helper"

RSpec.describe "Creating a support request", type: :request do
  context "a previously unsubmitted request exists" do
    let(:user) { create(:user) }
    let!(:pending_support_request) { create(:support_request, :pending, user: user) }

    before do 
      user_is_signed_in(user: user)
      get new_support_request_path
    end

    it "redirects the user to that request for editing or submission" do
      expect(response).to redirect_to(support_request_path(pending_support_request))
    end
  end
end