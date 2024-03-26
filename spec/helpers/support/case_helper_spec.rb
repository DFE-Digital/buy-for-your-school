require "rails_helper"

describe Support::CaseHelper do
  describe "#other_cases_by_case_org_path" do
    let(:organisation) { build(:support_organisation, name: "Test School") }
    let(:back_to) { "back_link" }
    let(:expected_params) do
      {
        back_to:,
        search_case_form: {
          search_term: organisation.name,
          state: %w[initial opened resolved on_hold pipeline no_response],
          exact_match: true,
        },
      }
    end

    it "returns the case search link with the correct search parameters, excluding the 'closed' state" do
      expect(helper.other_cases_by_case_org_path(organisation, back_to:)).to eq("/support/cases/find-a-case?#{expected_params.to_query}")
    end
  end

  describe "#other_cases_by_case_org_exist?" do
    let(:organisation) { create(:support_organisation, name: "Test School") }

    context "when there are more than 1 cases that belong to the same organisation and are not closed" do
      before do
        create(:support_case, state: :initial, organisation:)
        create(:support_case, state: :opened, organisation:)
        create(:support_case, state: :resolved, organisation:)
      end

      it "returns true" do
        expect(helper.other_cases_by_case_org_exist?(organisation)).to be(true)
      end
    end

    context "when there is 1 or no cases that belong to the same organisation and are not closed" do
      before do
        create(:support_case, state: :initial, organisation:)
        create(:support_case, state: :closed, organisation:)
      end

      it "returns false" do
        expect(helper.other_cases_by_case_org_exist?(organisation)).to be(false)
      end
    end
  end
end
