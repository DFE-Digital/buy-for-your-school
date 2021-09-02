RSpec.describe Support::InteractionPresenter do
  let(:interaction) { OpenStruct.new(note: "\n foo \n") }

  subject(:presenter) { described_class.new(interaction) }

  describe "#note" do
    it "returns the note stripped out of trailing new lines" do
      expect(presenter.note).to eq("foo")
    end
  end
end
