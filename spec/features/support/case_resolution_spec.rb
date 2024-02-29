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
        "template_id": "16d745fd-38fb-4a1e-9204-ca9b95a4288b",
        "reference": "000001",
        "personalisation": {
          "reference": "000001",
          "first_name": "School",
          "last_name": "Contact",
          "email": "school@email.co.uk",
          "caseworker_name": "first_name last_name",
          "very_satisfied_link": %r{very_satisfied$},
          "satisfied_link": %r{satisfied$},
          "neither_link": %r{neither$},
          "dissatisfied_link": %r{dissatisfied$},
          "very_dissatisfied_link": %r{very_dissatisfied$},
        },
      })
      .to_return(body: {}.to_json, status: 200, headers: {})

    visit support_case_path(support_case)
    click_link "Resolve case"
  end

  context "when providing notes" do
    before do
      fill_in "Resolve case", with: "A note when resolving the case"
      click_button "Save and close case"
    end

    it "resolves the case" do
      expect(page).to have_content("Case resolved successfully")

      within "#case-history tr", text: "Status change" do
        expect(page).to have_text "From open to resolved by Procurement Specialist on #{Time.zone.now.to_formatted_s(:short)}: A note when resolving the case"
      end

      expect(page).to have_content("Case owner: first_name last_name")
    end
  end
end
