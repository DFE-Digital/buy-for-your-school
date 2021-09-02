RSpec.describe Support::BasePresenter do
  let(:created_at) { Time.zone.local(2000, 1, 30, 12) }
  let(:updated_at) { Time.zone.local(2000, 3, 30, 12) }
  let(:model) { OpenStruct.new(created_at: created_at, updated_at: updated_at) }

  subject(:presenter)  { described_class.new(model) }

  describe "#created_at" do
    it "returns a better formatted timestamp" do
      expect(presenter.created_at).to eq("30 January 2000")
    end
  end

  describe "#updated_at" do
    it "returns a better formatted timestamp" do
      expect(presenter.updated_at).to eq("30 March 2000")
    end
  end
end
