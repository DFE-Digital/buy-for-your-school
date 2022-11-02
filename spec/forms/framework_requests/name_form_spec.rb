describe FrameworkRequests::NameForm, type: :model do
  subject(:form) { described_class.new(id: framework_request.id) }

  describe "validation" do
    describe "first_name" do
      let(:framework_request) { create(:framework_request, first_name: nil) }

      it { is_expected.to validate_presence_of(:first_name) }

      context "when validation fails" do
        it "gives an error message" do
          expect(form).not_to be_valid
          expect(form.errors.messages[:first_name]).to eq ["Enter your first name"]
        end
      end
    end

    describe "last_name" do
      let(:framework_request) { create(:framework_request, last_name: nil) }

      it { is_expected.to validate_presence_of(:last_name) }

      context "when validation fails" do
        it "gives an error message" do
          expect(form).not_to be_valid
          expect(form.errors.messages[:last_name]).to eq ["Enter your last name"]
        end
      end
    end
  end
end
