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

  context "with local authority defined" do
    let(:organisation) { create(:support_organisation, local_authority: { "code": 1, "name": "Authority" }) }

    describe "#local_authority" do
      it "returns the local authority name" do
        expect(presenter.local_authority).to eq "Authority"
      end
    end
  end

  context "with no local authority defined" do
    let(:organisation) { create(:support_organisation, local_authority: nil) }

    describe "#local_authority" do
      it "returns nil" do
        expect(presenter.local_authority).to be_nil
      end
    end
  end

  context "with contact defined" do
    let(:organisation) { create(:support_organisation, contact: { "title": "Ms", "first_name": "School", "last_name": "Contact" }) }

    describe "#contact" do
      it "returns the full contact name" do
        expect(presenter.contact).to eq "Ms School Contact"
      end
    end
  end

  context "with no contact defined" do
    let(:organisation) { create(:support_organisation, contact: {}) }

    describe "#contact" do
      it "returns blank string" do
        expect(presenter.contact).to eq "  "
      end
    end
  end

  context "with phase defined" do
    let(:organisation) { create(:support_organisation, phase: 3) }

    describe "#phase" do
      it "returns human-readable phase" do
        expect(presenter.phase).to eq "Middle primary"
      end
    end
  end

  context "with no phase defined" do
    let(:organisation) { create(:support_organisation, phase: nil) }

    describe "#phase" do
      it "returns nil" do
        expect(presenter.phase).to be_nil
      end
    end
  end
end
