RSpec.describe NewJourneyForm do
  subject(:form) { described_class.new(name: "Test spec", category: "catering", user:) }

  let(:user) { create(:user) }

  before do
    create(:category, :catering)
  end

  describe "#data" do
    it "returns form values ready for persisting" do
      expect(form.data).to eql(
        name: "Test spec",
        category: Category.first,
        user:,
      )
    end
  end

  describe "#get_category" do
    it "returns the category by slug" do
      expect(form.get_category).to eq Category.first
    end
  end

  describe "#go_back" do
    it "returns current form params with back set to true" do
      expect(form.go_back).to eql(
        name: "Test spec",
        category: "catering",
        back: true,
        step: 1,
      )
    end
  end
end
