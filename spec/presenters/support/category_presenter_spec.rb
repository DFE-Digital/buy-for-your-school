RSpec.describe Support::CategoryPresenter do
  subject(:presenter) { described_class.new(category) }

  let(:category) { OpenStruct.new(title: "Catering") }

  describe "#title" do
    it "returns a placeholder for title" do
      expect(presenter.title).to eq("n/a")
    end
  end
end
