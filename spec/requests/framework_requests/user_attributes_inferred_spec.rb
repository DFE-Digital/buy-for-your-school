require "rails_helper"

describe "Inferring signed-in user's details" do
  context "when a new request is started by a signed-in user" do
    let(:user) { build(:user, :one_supported_group) }
    let(:catering_category) { create(:request_for_help_category, slug: "catering") }

    before do
      user_is_signed_in(user:)
      create(:support_establishment_group, uid: "2314")
    end

    it "infers the user's details" do
      expect { post(categories_framework_requests_path, params: { framework_support_form: { category_slug: catering_category.slug } }) }.to change(FrameworkRequest, :count).from(0).to(1)
      expect(FrameworkRequest.first.user).to eq(user)
      expect(FrameworkRequest.first.first_name).to eq("first_name")
      expect(FrameworkRequest.first.last_name).to eq("last_name")
      expect(FrameworkRequest.first.email).to eq("test@test")
      expect(FrameworkRequest.first.org_id).to eq("2314")
      expect(FrameworkRequest.first.group).to eq(true)
    end
  end
end
