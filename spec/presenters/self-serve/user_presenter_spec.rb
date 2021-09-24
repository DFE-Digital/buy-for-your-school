RSpec.describe UserPresenter do
  subject(:presenter) { described_class.new(user) }

  describe "#full_name" do
    context "if a full name exists" do
      let(:user) { build(:user, full_name: "Ms Phoebe Buffay", first_name: "Phoebe", last_name: "Buffay") }

      it "returns the full name" do
        expect(presenter.full_name).to eq "Ms Phoebe Buffay"
      end
    end

    context "if a full name does not exist" do
      let(:user) { build(:user, full_name: nil, first_name: "Phoebe", last_name: "Buffay") }

      it "returns the first name and last name" do
        expect(presenter.full_name).to eq "Phoebe Buffay"
      end
    end
  end

  describe "#journeys" do
    let(:user) { build(:user, journeys: [build(:journey), build(:journey)]) }

    it "returns journey presenters" do
      expect(presenter.journeys).to be_kind_of(Array)
      expect(presenter.journeys.all? { |j| j.class == JourneyPresenter }).to be true
    end
  end
end