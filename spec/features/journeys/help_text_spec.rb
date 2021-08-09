RSpec.feature "Help Text" do
  let(:user) { create(:user) }
  let(:fixture) { "markdown-help-text.json" }

  before do
    user_is_signed_in(user: user)
    # TODO: setup with factory
    start_journey_from_category(category: fixture)
  end

  context "when the help text contains Markdown" do
    scenario "paragraph breaks are parsed as expected" do
      click_first_link_in_section_list

      # /journeys/302e58f4-01b3-469a-906e-db6991184699/steps/46005bbe-1aa2-49bf-b0df-0f027522f50d
      expect(page).to have_current_path %r{/journeys/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})/steps/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})}
      expect(find("div.govuk-hint")).to have_text "Paragraph Test: Paragraph 1"
      expect(find("div.govuk-hint")).to have_text "Paragraph Test: Paragraph 2"
    end

    scenario "bold text is parsed as expected" do
      click_first_link_in_section_list

      # /journeys/302e58f4-01b3-469a-906e-db6991184699/steps/46005bbe-1aa2-49bf-b0df-0f027522f50d
      expect(page).to have_current_path %r{/journeys/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})/steps/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})}
      within("div.govuk-hint") do
        expect(page.html).to include("<strong>Bold text</strong> test")
      end
    end

    scenario "lists are parsed as expected" do
      click_first_link_in_section_list

      # /journeys/302e58f4-01b3-469a-906e-db6991184699/steps/46005bbe-1aa2-49bf-b0df-0f027522f50d
      expect(page).to have_current_path %r{/journeys/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})/steps/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})}
      within("div.govuk-hint") do
        expect(page.html).to include("<li>List item one</li>")
        expect(page.html).to include("<li>List item two</li>")
        expect(page.html).to include("<li>List item three</li>")
      end
    end
  end

  context "when the help text is nil" do
    context "when the question is a radio" do
      let(:fixture) { "nil-help-text-radios.json" }

      scenario "step page still renders" do
        start_journey_from_category(category: "nil-help-text-radios.json")
        click_first_link_in_section_list

        # /journeys/302e58f4-01b3-469a-906e-db6991184699/steps/46005bbe-1aa2-49bf-b0df-0f027522f50d
        expect(page).to have_current_path %r{/journeys/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})/steps/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})}
        expect(find("div.govuk-form-group")).to have_text "Which service do you need?"
      end
    end

    context "when question is a short text" do
      let(:fixture) { "nil-help-text-short-text.json" }

      scenario "step page still renders " do
        click_first_link_in_section_list

        # /journeys/302e58f4-01b3-469a-906e-db6991184699/steps/46005bbe-1aa2-49bf-b0df-0f027522f50d
        expect(page).to have_current_path %r{/journeys/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})/steps/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})}
        expect(find("div.govuk-form-group")).to have_text "What email address did you use?"
      end
    end
  end
end
