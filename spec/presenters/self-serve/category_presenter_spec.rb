RSpec.describe CategoryPresenter do
  let(:category) { build(:category) }

  describe "#title_downcase" do
    it "downcases everything but acronyms" do
      category = build(:category, title: "Capitalised XYZs String")
      presenter = described_class.new(category)
      expect(presenter.title_downcase).to eq "capitalised XYZs string"
    end
  end
end
