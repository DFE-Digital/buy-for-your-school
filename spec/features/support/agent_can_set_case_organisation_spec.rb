require "rails_helper"

describe "Agent can set a case's establishment", js: true do
  include_context "with an agent"

  before do
    create(:support_organisation, name: "Organisation 1", urn: "101999")
    create(:support_organisation, name: "Organisation 2", urn: "888999")
    create(:support_organisation, name: "School 1", urn: "102678")
    create(:support_establishment_group, name: "Federated group of schools", ukprn: "789456")
    create(:support_establishment_group, name: "Other group", ukprn: "1234567")

    visit support_case_path(support_case)
  end

  context "when the case has no organisation set already" do
    let(:support_case) { create(:support_case, organisation: nil) }

    describe "selecting an organisation" do
      before { select_organisation(search_term: "Scho", option_to_select: "School 1") }

      it "sets that choice as the organisation for the case" do
        expect(support_case.reload.organisation.urn).to eq("102678")
      end
    end

    describe "selecting a group" do
      before { select_organisation(search_term: "Fed", option_to_select: "Federated group of schools") }

      it "sets that choice as the organisation for the case" do
        expect(support_case.reload.organisation.ukprn).to eq("789456")
      end
    end
  end

  context "when the case already has an organisation assigned as establishment" do
    let(:support_case) { create(:support_case, organisation: Support::Organisation.find_by(name: "School 1")) }

    describe "selecting a group" do
      before { select_organisation(search_term: "Oth", option_to_select: "Other group", add_or_change: "Change") }

      it "sets that choice as the organisation for the case" do
        expect(support_case.reload.organisation.ukprn).to eq("1234567")
      end
    end
  end

  context "when the case already has a group assigned as establishment" do
    let(:support_case) { create(:support_case, organisation: Support::EstablishmentGroup.find_by(name: "Federated group of schools")) }

    describe "selecting a group" do
      before { select_organisation(search_term: "Org", option_to_select: "Organisation 1", add_or_change: "Change") }

      it "sets that choice as the organisation for the case" do
        expect(support_case.reload.organisation.urn).to eq("101999")
      end
    end
  end

  def select_organisation(search_term:, option_to_select:, add_or_change: "Add")
    within ".govuk-summary-list__row", text: "Organisation name" do
      click_link add_or_change
    end
    fill_in "What Organisation do you want to add?", with: search_term
    find(".autocomplete__option", text: option_to_select).click
    click_button "Save selected organisation"
  end
end
