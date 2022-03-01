RSpec.describe Support::EditCaseForm, type: :model do
  subject(:form) { described_class.new }

  describe "#to_h" do
    subject(:form) { described_class.new(request_text: "help") }

    it "returns form values" do
      expect(form.to_h).to eql({
        request_text: "help",
      })
    end
  end
end
