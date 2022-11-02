describe FrameworkRequests::MessageForm, type: :model do
  subject(:form) { described_class.new(id: framework_request.id) }

  let(:framework_request) { create(:framework_request, message_body: nil) }

  describe "validation" do
    describe "message_body" do
      it { is_expected.to validate_presence_of(:message_body) }

      context "when validation fails" do
        it "gives an error message" do
          expect(form).not_to be_valid
          expect(form.errors.messages[:message_body]).to eq ["You must tell us how we can help"]
        end
      end
    end
  end
end
