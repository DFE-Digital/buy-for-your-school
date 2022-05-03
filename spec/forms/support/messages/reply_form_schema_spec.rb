RSpec.describe Support::Messages::ReplyFormSchema do
  subject(:schema) { described_class.new.call(nil) }

  describe "validates body" do
    context "when it is blank" do
      subject(:schema) { described_class.new.call(body: "") }

      it "raises a validation error" do
        expect(schema.errors.messages.size).to eq 1
        expect(schema.errors.messages[0].to_s).to eq "The reply body cannot be blank"
      end
    end
  end
end
