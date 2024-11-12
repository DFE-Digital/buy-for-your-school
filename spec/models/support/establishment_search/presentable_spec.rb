require "rails_helper"

describe Support::EstablishmentSearch::Presentable do
  subject(:presentable) { Support::EstablishmentSearch }

  let!(:opening_school) { create(:support_organisation, :with_address, name: "Test Opening School", urn: "3", ukprn: "333", status: 4, opened_date: "2024-07-30", establishment_type: create(:support_establishment_type, name: "Foundation school")) }
  let!(:closing_school) { create(:support_organisation, :with_address, name: "Test Closing School", urn: "2", ukprn: "222", status: 3, opened_date: "2000-08-30", closed_date: "2024-08-30", establishment_type: create(:support_establishment_type, name: "Academy sponsor led")) }
  let!(:open_school) { create(:support_organisation, :with_address, name: "Test Primary School", urn: "1", ukprn: "123", status: 1, opened_date: "2000-09-30", establishment_type: create(:support_establishment_type, name: "Community school")) }
  let!(:group) { create(:support_establishment_group, :with_address, name: "Test MAT", uid: "2", ukprn: "456", establishment_group_type: create(:support_establishment_group_type, name: "Multi-academy Trust")) }
  let!(:local_authority) { create(:local_authority, name: "Camden", la_code: "3") }

  describe "#autocomplete_template" do
    context "when the search result is an opening school with a date" do
      it "returns an autocomplete template with the name, postcode, school type, status, open date, urn and ukprn" do
        search_result = presentable.omnisearch(opening_school.urn).to_a.first
        expect(search_result.autocomplete_template).to eq("<strong>Test Opening School</strong>, EC3A 5DE<br />Foundation school<br />Proposed to open 30 Jul 24<br />URN: 3 - UKPRN: 333\n")
      end
    end

    context "when the search result is a closing school with a date" do
      it "returns an autocomplete template with the name, postcode, school type, status, closed date, urn and ukprn" do
        search_result = presentable.omnisearch(closing_school.urn).to_a.first
        expect(search_result.autocomplete_template).to eq("<strong>Test Closing School</strong>, EC3A 5DE<br />Academy sponsor led<br />Open, but proposed to close 30 Aug 24<br />URN: 2 - UKPRN: 222\n")
      end
    end

    context "when the search result is an open school" do
      it "returns an autocomplete template with the name, postcode, school type, urn and ukprn" do
        search_result = presentable.omnisearch(open_school.urn).to_a.first
        expect(search_result.autocomplete_template).to eq("<strong>Test Primary School</strong>, EC3A 5DE<br />Community school<br />URN: 1 - UKPRN: 123\n")
      end
    end

    context "when the search result is a group" do
      it "returns an autocomplete template with the name, postcode, group type, urn and ukprn" do
        search_result = presentable.omnisearch(group.name).to_a.first
        expect(search_result.autocomplete_template).to eq("<strong>Test MAT</strong>, EC1M 6HR<br />Multi-academy Trust<br />URN:  - UKPRN: 456\n")
      end
    end

    context "when the search result is a local authority" do
      it "returns an autocomplete template with the name, org type (Local Authority) and LA code" do
        search_result = presentable.omnisearch(local_authority.name).to_a.first
        expect(search_result.autocomplete_template).to eq("<strong>Camden</strong><br />Local authority<br />Code: 3\n")
      end
    end
  end
end
