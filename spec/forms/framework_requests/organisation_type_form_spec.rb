describe FrameworkRequests::OrganisationTypeForm, type: :model do
  subject(:form) { described_class.new(id: framework_request.id, school_type: nil) }

  let(:framework_request) { create(:framework_request) }

  describe "validation" do
    describe "school_type" do
      it { is_expected.to validate_presence_of(:school_type) }

      context "when validation fails" do
        it "gives an error message" do
          expect(form).not_to be_valid
          expect(form.errors.messages[:school_type]).to eq ["Select what type of organisation you're buying for"]
        end
      end
    end
  end
end
