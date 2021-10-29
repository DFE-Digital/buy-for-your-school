RSpec.describe Support::CategoryPresenter do
  subject(:presenter) { described_class.new(category) }

  context "with category defined" do
    let(:category) { OpenStruct.new(title: "Catering") }

    describe "#title" do
      it "returns a placeholder for title" do
        expect(presenter.title).to eq("Catering")
      end
    end
  end

  context "with no category defined" do
    let(:category) { nil }

    describe "#title" do
      it "returns a placeholder for title" do
        expect(presenter.title).to eq("n/a")
      end
    end
  end
end
