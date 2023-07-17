require "rails_helper"

describe "Agent can change case summary", js: true do
  include_context "with an agent"

  let!(:need_stage) { create(:support_procurement_stage, title: "Need", stage: 0, key: "need") }
  let!(:tender_prep_stage) { create(:support_procurement_stage, title: "Tender preparation", stage: 2, key: "tender_preparation") }

  let(:support_case) { create(:support_case, support_level: :L1, value: nil, source: "nw_hub", category: gas_category, procurement_stage: need_stage) }

  before do
    define_basic_categories
    define_basic_queries

    visit support_case_path(support_case)
    click_on "Case details"
    within "h3", text: "Case summary - change" do
      click_link "change"
    end
  end

  context "when the support level is updated" do
    before do
      choose "2 - Specific advice"
      click_button "Continue"
      click_button "Save"
      support_case.reload
    end

    it "persists the changed support_level" do
      expect(support_case.support_level).to eq "L2"
    end

    it "creates a support level changed interaction" do
      interaction = Support::Interaction.first

      expect(interaction.body).to eq "Support level change"
      expect(interaction.additional_data).to eq({
        "from" => "L1",
        "to" => "L2",
      })
    end
  end

  context "when the procurement stage is updated" do
    before do
      choose "4 - DfE buying through a framework"
      select "Tender preparation", from: "Procurement stage"
      click_button "Continue"
      click_button "Save"
    end

    it "persists the changed procurement stage" do
      expect(support_case.reload.procurement_stage.title).to eq "Tender preparation"
    end

    it "creates a procurement stage changed interaction" do
      interaction = Support::Interaction.first

      expect(interaction.body).to eq "Procurement stage change"
      expect(interaction.additional_data).to eq({
        "from" => need_stage.id,
        "to" => tender_prep_stage.id,
      })
    end
  end

  context "when the case value is updated" do
    before do
      fill_in "Case value or estimated contract value (optional)", with: "123.32"
      click_button "Continue"
      click_button "Save"
      support_case.reload
    end

    it "persists the changed case value" do
      expect(support_case.value).to eq(123.32)
    end

    it "creates a value change interaction" do
      interaction = Support::Interaction.first

      expect(interaction.body).to eq "Case value changed"
      expect(interaction.additional_data).to eq({
        "format_version" => "2",
        "procurement_value" => "123.32",
      })
    end
  end

  context "when the case source is updated" do
    before do
      select "Email", from: "Case source"
      click_button "Continue"
      click_button "Save"
      support_case.reload
    end

    it "persists the changed case source" do
      expect(support_case.source).to eq "incoming_email"
    end

    it "creates a source change interaction" do
      interaction = Support::Interaction.first
      expect(interaction.body).to eq "Source changed"
      expect(interaction.additional_data).to eq({
        "format_version" => "2",
        "source" => "incoming_email",
      })
    end
  end

  describe "Agent changes from procurement category to query" do
    before do
      choose "Non-procurement"
      select "Other", from: "select_request_details_query_id"
      find("#request_details_other_query_text").set("Other Query Details")
      click_continue
    end

    it "allows the user to check their answers" do
      within ".govuk-summary-list__row", text: "Query" do
        expect(page).to have_content("Other - Other Query Details")
      end
    end

    describe "submitting results" do
      it "shows the new category in case details" do
        click_button "Save"

        within ".govuk-summary-list__row", text: "Query" do
          expect(page).to have_content("Other - Other Query Details")
        end
      end
    end
  end
end
