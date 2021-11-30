RSpec.describe Support::OrganisationPresenter do
  subject(:presenter) { described_class.new(organisation) }

  context "with address defined" do
    let(:organisation) { create(:support_organisation, :with_address) }

    describe "#formatted_address" do
      it "returns a correctly address formatted" do
        expect(presenter.formatted_address).to eq("St James's Passage, Duke's Place, EC3A 5DE")
      end
    end
  end

  context "with no address defined" do
    let(:organisation) { create(:support_organisation) }

    describe "#formatted_address" do
      it "returns a correctly address formatted" do
        expect(presenter.formatted_address).to eq ""
      end
    end
  end
end
