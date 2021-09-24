RSpec.describe SupportRequestPresenter do
  subject(:presenter) { described_class.new(support_request) }

  let(:journey) { build(:journey) }
  let(:support_request) { build(:support_request, journey: journey) }

  describe "#journey" do
    it "returns a journey presenter" do
      expect(presenter.journey).to be_kind_of(JourneyPresenter)
    end
  end
end
