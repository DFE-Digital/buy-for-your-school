require "rails_helper"

describe Support::CaseSearch do
  context "when a case exists with ref 000123" do
    it "returns this case by searching 123" do
      create(:support_case, ref: "000123")
      results = described_class.find_a_case("123")
      expect(results.count).to eq(1)
      expect(results.first.case_ref).to eq("000123")
    end
  end

  context "when searching by contact email" do
    let(:search_term) { "school_user@school1.com" }

    before do
      create(:support_case, email: "school_user@school1.com", ref: "000001")
      create(:support_case, email: "School_User@School1.com", ref: "000002")
      create(:support_case, email: "school_team@school2.ac.uk", ref: "000003")
      create(:support_case, email: "procurement@school3.co.uk", ref: "000004")
    end

    it "finds the relevant cases" do
      results = described_class.find_a_case(search_term)
      expect(results.count).to eq(2)
      expect(results.pluck(:case_ref)).to match_array(%w[000001 000002])
    end
  end

  context "when searching by organisation name (exact match)" do
    let(:search_term) { "Camden" }

    before do
      school = create(:support_organisation, name: "Camden Primary School")
      group = create(:support_establishment_group, name: "Camden Academy Trust")
      local_authority = create(:local_authority, name: "Camden")

      create(:support_case, ref: "000001", organisation: school)
      create(:support_case, ref: "000002", organisation: group)
      create(:support_case, ref: "000003", organisation: local_authority)
      create(:support_case, ref: "000004", organisation: local_authority)
    end

    it "finds the relevant cases" do
      results = described_class.find_a_case(search_term, exact_match: true)
      expect(results.count).to eq(2)
      expect(results.pluck(:case_ref)).to match_array(%w[000003 000004])
    end
  end
end
