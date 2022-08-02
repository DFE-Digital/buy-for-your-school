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
end
