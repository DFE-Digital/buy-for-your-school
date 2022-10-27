describe FrameworkRequests::ConfirmOrganisationForm, type: :model do
  subject(:form) { described_class.new(id: framework_request.id, school_type:, org_confirm:, org_id:, user: build(:guest)) }

  let(:framework_request) { create(:framework_request, org_id: nil) }
  let(:school_type) { "school" }
  let(:org_confirm) { nil }
  let(:org_id) { nil }

  describe "#save!" do
    context "when the organisation is confirmed" do
      let(:org_confirm) { true }
      let(:org_id) { "123" }

      it "persists the organisation" do
        form.save!

        expect(form.framework_request.org_id).to eq "123"
      end
    end

    context "when the organisation is not confirmed" do
      let(:org_confirm) { false }
      let(:org_id) { "123" }

      it "does not persist the organisation" do
        form.save!

        expect(form.framework_request.org_id).to be nil
      end
    end
  end

  describe "#org_confirm_validation" do
    context "when the selected school is missing confirmation" do
      it "returns the right error message" do
        form.org_confirm_validation

        expect(form).not_to be_valid
        expect(form.errors.messages[:org_confirm]).to eq ["Select whether this is the organisation you're buying for"]
      end
    end

    context "when the selected group is missing confirmation" do
      let(:school_type) { "group" }

      it "returns the right error message" do
        form.org_confirm_validation

        expect(form).not_to be_valid
        expect(form.errors.messages[:org_confirm]).to eq ["Select whether this is the Group or Trust you're buying for"]
      end
    end
  end

  describe "#common" do
    let(:org_id) { "123 - Test school" }

    it "includes the full organisation name" do
      expect(form.common).to include(org_id:)
    end
  end

  describe "#school_or_group" do
    context "when the user has chosen single school" do
      let(:organisation) { create(:support_organisation) }
      let(:framework_request) { create(:framework_request, org_id: organisation.urn) }

      it "returns the school" do
        expect(form.school_or_group).to eq organisation
      end
    end

    context "when the user has chosen trust or federation" do
      let(:school_type) { "group" }
      let(:org) { create(:support_establishment_group) }
      let(:framework_request) { create(:framework_request, org_id: org.uid) }

      it "returns the group" do
        expect(form.school_or_group).to eq org
      end
    end
  end
end
