describe FrameworkRequests::ConfirmSignInController, type: :controller do
  before { user_is_signed_in(user:) }

  context "when the user belongs to multiple organisations" do
    let(:user) { build(:user, :many_supported_schools) }

    it "redirects to the select organisation page" do
      post :create
      expect(response).to redirect_to "/procurement-support/select_organisation"
    end
  end

  context "when the user belongs to one organisation" do
    let(:user) { build(:user, :one_supported_school) }

    it "redirects to the categories page" do
      post :create
      expect(response).to redirect_to "/procurement-support/categories"
    end

    context "and the organisation is a MAT or federation with multiple schools" do
      let(:user) { build(:user, :one_supported_group) }

      before do
        establishment_group_type = create(:support_establishment_group_type, code: 6)
        create(:support_establishment_group, name: "Testing Multi Academy Trust", uid: "2314", establishment_group_type:)
        create_list(:support_organisation, 2, trust_code: "2314")
      end

      it "redirects to the school picker page" do
        post :create
        expect(response).to redirect_to "/procurement-support/school_picker"
      end
    end
  end
end
