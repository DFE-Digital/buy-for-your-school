require "rails_helper"

describe "Resolving a case" do
  include_context "with a cec agent"

  let(:dfe_energy_category) { create(:support_category, title: "DfE Energy for Schools service") }
  let(:existing_agent) { create(:support_agent) }
  let(:support_case) { create(:support_case, category: dfe_energy_category, state: :opened, agent: existing_agent) }

  before do
    # exit survey stub
    stub_request(:post, "https://api.notifications.service.gov.uk/v2/notifications/email")
      .with(body: {
        "email_address": "school@email.co.uk",
        "template_id": "28058b34-4f7f-4685-a529-8365e91e12d6",
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
          "10_link": %r{10$},
          "9_link": %r{9$},
          "8_link": %r{8$},
          "7_link": %r{7$},
          "6_link": %r{6$},
          "5_link": %r{5$},
          "4_link": %r{4$},
          "3_link": %r{3$},
          "2_link": %r{2$},
          "1_link": %r{1$},
          "0_link": %r{0$},
        },
      })
      .to_return(body: {}.to_json, status: 200, headers: {})

    visit cec_onboarding_case_path(support_case)
    click_link "Resolve case"
  end

  context "when providing notes" do
    before do
      fill_in "Resolve case", with: "A note when resolving the case"
      click_button "Save and close case"
    end

    it "resolves the case without sending an exit survey" do
      expect(page).to have_content("Case resolved successfully")

      within "#case-history tr", text: "Status change" do
        expect(page).to have_text "From open to resolved by Procurement Specialist on #{Time.zone.now.to_formatted_s(:short)}: A note when resolving the case"
      end

      expect(page).to have_content("Case owner: first_name last_name")

      expect(WebMock).not_to have_requested(:post, "https://api.notifications.service.gov.uk/v2/notifications/email")
    end
  end
end
