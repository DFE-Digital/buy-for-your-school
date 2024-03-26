require "rails_helper"

describe Support::EstablishmentSearch::Presentable do
  subject(:presentable) { Support::EstablishmentSearch }

  let!(:school) { create(:support_organisation, :with_address, name: "Test Primary School", urn: "1", ukprn: "123", establishment_type: create(:support_establishment_type, name: "Community school")) }
  let!(:group) { create(:support_establishment_group, :with_address, name: "Test MAT", uid: "2", ukprn: "456", establishment_group_type: create(:support_establishment_group_type, name: "Multi-academy Trust")) }
  let!(:local_authority) { create(:local_authority, name: "Camden", la_code: "3") }

  describe "#autocomplete_template" do
    context "when the search result is a school" do
      it "returns the correct autocomplete template" do
        search_result = presentable.omnisearch(school.urn).to_a.first
        expect(search_result.autocomplete_template).to eq("<strong>Test Primary School</strong>, EC3A 5DE<br />Community school<br />URN: 1 - UKPRN: 123\n")
      end
    end

    context "when the search result is a group" do
      it "returns the correct autocomplete template" do
        search_result = presentable.omnisearch(group.name).to_a.first
        expect(search_result.autocomplete_template).to eq("<strong>Test MAT</strong>, EC1M 6HR<br />Multi-academy Trust<br />URN:  - UKPRN: 456\n")
      end
    end

    context "when the search result is a local authority" do
      it "returns the correct autocomplete template" do
        search_result = presentable.omnisearch(local_authority.name).to_a.first
        expect(search_result.autocomplete_template).to eq("<strong>Camden</strong><br />Local authority<br />Code: 3\n")
      end
    end
  end
end
