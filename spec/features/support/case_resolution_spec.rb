require "rails_helper"

describe "Resolving a case" do
  include_context "with an agent"

  let(:existing_agent) { create(:support_agent) }
  let(:support_case) { create(:support_case, :opened, agent: existing_agent) }

  before do
    # exit survey stub
    stub_request(:post, "https://api.notifications.service.gov.uk/v2/notifications/email")
      .with(body: {
        "email_address": "school@email.co.uk",
        "template_id": "bbee99cd-c718-42ef-9d2c-b8fc9b442bbf",
        "reference": "000001",
        "personalisation": {
          "reference": "000001",
          "first_name": "School",
          "last_name": "Contact",
          "email": "school@email.co.uk",
          "caseworker_name": "first_name last_name",
          "extremely_satisfied_link": %r{extremely_satisfied$},
          "very_satisfied_link": %r{very_satisfied$},
          "neutral_link": %r{neutral$},
          "slightly_satisfied_link": %r{slightly_satisfied$},
          "not_satisfied_at_all_link": %r{not_satisfied_at_all$},
        },
      })
      .to_return(body: {}.to_json, status: 200, headers: {})

    visit support_case_path(support_case)
    click_link "Resolve case"
  end

  context "when providing notes" do
    let(:case_resolved_interaction) { support_case.reload.interactions.last }

    before do
      fill_in "Resolve case", with: "A note when resolving the case"
      click_button "Save and close case"
    end

    it "resolves the case" do
      expect(support_case.reload).to be_resolved
    end

    it "saves the given note to the case" do
      expect(case_resolved_interaction.body).to eq("From open to resolved by Procurement Specialist on #{Time.zone.now.to_formatted_s(:short)}: A note when resolving the case")
    end

    it "sets the current agent on the case note" do
      expect(case_resolved_interaction.agent).to eq(agent)
    end

    it "leaves the agent assigned to the case" do
      expect(support_case.reload.agent).to eq(existing_agent)
    end

    it "redirects the user back to the case" do
      expect(page).to have_current_path(support_case_path(support_case), ignore_query: true)
    end
  end

  context "when not providing notes" do
    before do
      click_button "Save and close case"
    end

    it "remains open" do
      expect(support_case.reload).to be_opened
    end

    it "tells the user to provide notes" do
      expect(page).to have_content("Please enter some closing notes to resolve the case")
    end
  end
end
