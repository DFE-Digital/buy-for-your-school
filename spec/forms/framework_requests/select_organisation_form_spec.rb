describe FrameworkRequests::SelectOrganisationForm, type: :model do
  subject(:form) { described_class.new(id: framework_request.id) }

  let(:framework_request) { create(:framework_request, org_id: nil) }

  describe "validation" do
    describe "org_id" do
      it { is_expected.to validate_presence_of(:org_id) }

      context "when validation fails" do
        it "gives an error message" do
          expect(form).not_to be_valid
          expect(form.errors.messages[:org_id]).to eq ["Select the school or group you want help buying for"]
        end
      end
    end
  end
end
