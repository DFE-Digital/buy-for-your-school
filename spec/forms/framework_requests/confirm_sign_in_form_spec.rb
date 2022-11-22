describe FrameworkRequests::ConfirmSignInForm, type: :model do
  subject(:form) { described_class.new(user:) }

  let(:user) { create(:user) }

  describe "#data" do
    it "includes the user" do
      expect(form.data).to include(user:)
    end

    it "includes the first name" do
      expect(form.data).to include(first_name: "first_name")
    end

    it "includes the last name" do
      expect(form.data).to include(last_name: "last_name")
    end

    it "includes the email" do
      expect(form.data).to include(email: "test@test")
    end

    context "when the organisation is a school" do
      let(:user) { create(:user, :one_supported_school) }
      let!(:organisation) { create(:support_organisation, urn: "100253") }

      it "includes the organisation and group fields" do
        expect(form.data).to include(organisation:)
        expect(form.data).to include(group: false)
      end
    end

    context "when the organisation is a group" do
      let(:user) { create(:user, :one_supported_group) }
      let!(:organisation) { create(:support_establishment_group, uid: "2314") }

      it "includes the organisation and group fields" do
        expect(form.data).to include(organisation:)
        expect(form.data).to include(group: true)
      end
    end
  end
end
