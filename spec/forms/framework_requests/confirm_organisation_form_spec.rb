describe FrameworkRequests::ConfirmOrganisationForm, type: :model do
  subject(:form) { described_class.new(id: framework_request.id, school_type:, org_confirm:, organisation_id:, organisation_type:, user: build(:guest)) }

  let(:framework_request) { create(:framework_request, organisation: nil) }
  let(:school_type) { "school" }
  let(:org_confirm) { nil }
  let(:organisation_id) { nil }
  let(:organisation_type) { nil }

  describe "#save!" do
    let(:organisation) { create(:support_organisation) }
    let(:organisation_id) { organisation.id }
    let(:organisation_type) { organisation.class.name }

    context "when the organisation is confirmed" do
      let(:org_confirm) { true }

      it "persists the organisation" do
        form.save!

        expect(form.framework_request.organisation).to eq organisation
      end
    end

    context "when the organisation is not confirmed" do
      let(:org_confirm) { false }

      it "does not persist the organisation" do
        form.save!

        expect(form.framework_request.organisation_id).to be nil
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
    let(:organisation_id) { "123 - Test school" }

    it "includes the full organisation name" do
      expect(form.common).to include(organisation_id:)
    end
  end

  describe "#data" do
    let(:organisation) { create(:support_organisation) }
    let(:organisation_id) { organisation.id }
    let(:organisation_type) { organisation.class.name }

    it "includes the organisation" do
      expect(form.data).to include(organisation:)
    end

    it "includes the group value" do
      expect(form.data).to include(group: false)
    end

    it "excludes the organisation_id" do
      expect(form.data).not_to include(:organisation_id)
    end
  end

  describe "#school_or_group" do
    context "when the user has chosen single school" do
      let(:organisation) { create(:support_organisation) }
      let(:framework_request) { create(:framework_request, organisation:) }

      it "returns the school" do
        expect(form.school_or_group).to eq organisation
      end
    end

    context "when the user has chosen trust or federation" do
      let(:school_type) { "group" }
      let(:org) { create(:support_establishment_group) }
      let(:framework_request) { create(:framework_request, organisation: org) }

      it "returns the group" do
        expect(form.school_or_group).to eq org
      end
    end
  end
end
