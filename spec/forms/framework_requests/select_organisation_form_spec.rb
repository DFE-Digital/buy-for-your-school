describe FrameworkRequests::SelectOrganisationForm, type: :model do
  subject(:form) { described_class.new(id: framework_request.id, organisation_id:) }

  let(:organisation_id) { nil }
  let(:framework_request) { create(:framework_request, organisation: nil) }

  describe "validation" do
    describe "organisation_id" do
      it { is_expected.to validate_presence_of(:organisation_id) }

      context "when validation fails" do
        it "gives an error message" do
          expect(form).not_to be_valid
          expect(form.errors.messages[:organisation_id]).to eq ["Select the school or group you want help buying for"]
        end
      end
    end
  end

  describe "#data" do
    let(:organisation) { create(:support_organisation) }
    let(:organisation_id) { organisation.gias_id }

    it "includes the organisation" do
      expect(form.data).to include(organisation:)
    end

    it "excludes the organisation_id" do
      expect(form.data).not_to include(:organisation_id)
    end
  end
end
