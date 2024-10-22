require "rails_helper"

describe Support::EstablishmentSearch do
  before do
    create(:support_organisation, :with_address, name: "Test Opening School", urn: "1231", ukprn: "5", status: 4)
    create(:support_organisation, :with_address, name: "Test Closed School", urn: "1232", ukprn: "6", status: 2)
    create(:support_organisation, :with_address, name: "Test Open School", urn: "1233", ukprn: "7", status: 1)
    create(:support_organisation, :with_address, name: "Test Archived School", urn: "1234", ukprn: "7", status: 1, archived: true)
    create(:support_establishment_group, :with_address, name: "Test MAT", uid: "1", ukprn: "8")
    create(:local_authority, name: "Camden", la_code: "456")
  end

  describe "establishment search" do
    context "when searching for an establishment by name" do
      it "returns establishments that contain the same string and are not closed or archived" do
        results = described_class.omnisearch("Tes")
        expect(results.count).to eq(3)
        expect(results.pluck(:name)).to contain_exactly("Test Opening School", "Test Open School", "Test MAT")
      end
    end

    context "when searching for an establishment by urn" do
      it "returns establishments that contain the same urn string and are not closed or archived" do
        results = described_class.omnisearch("123")
        expect(results.count).to eq(2)
        expect(results.pluck(:name)).to contain_exactly("Test Opening School", "Test Open School")
      end
    end

    context "when searching for an establishment by code" do
      it "returns establishments that contain the same string and are not closed or archived" do
        results = described_class.omnisearch("456")
        expect(results.count).to eq(1)
        expect(results.pluck(:name)).to contain_exactly("Camden")
      end
    end

    context "when searching for an establishment by postcode" do
      it "returns establishments that contain the same string and are not closed or archived" do
        results = described_class.omnisearch("EC3A 5DE") # postcode from organisation with_address trait
        expect(results.count).to eq(2)
        expect(results.pluck(:name)).to contain_exactly("Test Opening School", "Test Open School")
      end
    end
  end  
end
