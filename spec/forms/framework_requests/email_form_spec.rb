describe FrameworkRequests::EmailForm, type: :model do
  subject(:form) { described_class.new(id: framework_request.id) }

  let(:framework_request) { create(:framework_request, email: nil) }

  describe "validation" do
    describe "email" do
      it { is_expected.to validate_presence_of(:email) }

      context "when validation fails" do
        it "gives an error message" do
          expect(form).not_to be_valid
          expect(form.errors.messages[:email]).to eq ["Enter an email in the correct format. For example, 'someone@school.sch.uk'."]
        end
      end
    end
  end
end
