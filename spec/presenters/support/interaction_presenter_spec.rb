require "rails_helper"

RSpec.describe Support::InteractionPresenter do
  let(:presenter) { described_class.new(OpenStruct(note: "\n foo \n")) }

  describe "#note" do
    it "returns the note stripped out of trailing new lines" do
      expect(presenter.note).to eq("foo")
    end
  end
end
