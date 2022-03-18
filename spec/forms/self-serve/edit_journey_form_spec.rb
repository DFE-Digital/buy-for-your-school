RSpec.describe EditJourneyForm do
  subject(:form) { described_class.new(name: "Test spec") }

  describe "#data" do
    it "returns form values ready for persisting" do
      expect(form.data).to eql(
        name: "Test spec",
      )
    end
  end
end
