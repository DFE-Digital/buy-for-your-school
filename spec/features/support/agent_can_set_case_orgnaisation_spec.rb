require "rails_helper"

describe "Agent can set a case's organisation" do
  include_context "with an agent"

  before do
    create(:support_organisation, name: "Organisation 1", urn: "101999")
    create(:support_organisation, name: "Organisation 2", urn: "888999")
    create(:support_organisation, name: "School 1", urn: "102678")

    click_button "Agent Login"
    visit support_case_path(support_case)
  end

  context "when the case has no organisation set already" do
    let(:support_case) { create(:support_case, organisation: nil) }

    describe "selecting an organisation", js: true do
      before { update_case_organisation(search_term: "Scho", option_to_select: "School 1") }

      it "sets that choice as the organisation for the case" do
        expect(support_case.reload.organisation.urn).to eq("102678")
      end
    end
  end

  context "when the case already has an organisation assigned" do
    let(:support_case) { create(:support_case, organisation: Support::Organisation.first) }

    describe "selecting an organisation", js: true do
      before { update_case_organisation(search_term: "Org", option_to_select: "Organisation 1", add_or_change: "Change") }

      it "sets that choice as the organisation for the case" do
        expect(support_case.reload.organisation.urn).to eq("101999")
      end
    end
  end

  def update_case_organisation(search_term:, option_to_select:, add_or_change: "Add")
    within ".govuk-summary-list__row", text: "Organisation name" do
      click_link add_or_change
    end
    fill_in "What Organisation do you want to add?", with: search_term
    find(".autocomplete__option", text: option_to_select).click
    click_button "Save selected organisation"
  end
end
