describe FrameworkRequests::EmailForm, type: :model do
  subject(:form) { described_class.new(id: framework_request.id) }

  let(:framework_request) { create(:framework_request, email:) }
  let(:email) { nil }

  describe "validation" do
    describe "email" do
      it { is_expected.to validate_presence_of(:email) }

      context "when blank" do
        let(:email) { "" }

        it "gives an error message" do
          expect(form).not_to be_valid
          expect(form.errors.messages[:email]).to eq ["Enter an email address", "Enter an email in the correct format. For example, 'someone@school.sch.uk'."]
        end
      end

      context "when invalid" do
        let(:email) { "invalid_email" }

        it "gives an error message" do
          expect(form).not_to be_valid
          expect(form.errors.messages[:email]).to eq ["Enter an email in the correct format. For example, 'someone@school.sch.uk'."]
        end
      end
    end
  end
end
