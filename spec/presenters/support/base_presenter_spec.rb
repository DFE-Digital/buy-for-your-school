RSpec.describe Support::BasePresenter do
  subject(:presenter) { described_class.new(model) }

  let(:model) { OpenStruct.new(created_at:, updated_at:) }

  let(:created_at) { Time.zone.local(2000, 1, 30, 12) }
  let(:updated_at) { Time.zone.local(2000, 3, 30, 12) }

  describe "#created_at" do
    it "formats the date" do
      expect(presenter.created_at).to eq("30 January 2000")
    end
  end

  describe "#updated_at" do
    it "formats the date" do
      expect(presenter.updated_at).to eq("30 March 2000")
    end
  end
end
