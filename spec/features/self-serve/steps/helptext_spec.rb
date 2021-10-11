RSpec.feature "Step help text is markdown" do
  context "and present" do
    before do
      user_is_signed_in
      start_journey_from_category(category: "markdown-help-text.json")
      click_first_link_in_section_list
    end

    scenario "paragraphs" do
      within ".govuk-hint" do
        expect(source).to include "<p>Paragraph Test: Paragraph 1</p>"
        expect(source).to include "<p>Paragraph Test: Paragraph 2</p>"
      end
    end

    scenario "bold text" do
      within ".govuk-hint" do
        expect(source).to include "<strong>Bold text</strong> test"
      end
    end

    scenario "italic text" do
      within ".govuk-hint" do
        expect(source).to include "<em>Italic text</em> test"
      end
    end

    scenario "list items" do
      within ".govuk-hint" do
        expect(source).to include "<li>List item one</li>"
        expect(source).to include "<li>List item two</li>"
        expect(source).to include "<li>List item three</li>"
      end
    end
  end

  # TODO: is this test really adding value?
  context "and omitted" do
    it "still renders when question is a radio" do
      user_is_signed_in
      start_journey_from_category(category: "nil-help-text-radios.json")
      click_first_link_in_section_list
      expect(find("legend.govuk-fieldset__legend--l")).to have_text "Which service do you need?"
    end

    it "still renders when question is a short text" do
      user_is_signed_in
      start_journey_from_category(category: "nil-help-text-short-text.json")
      click_first_link_in_section_list
      within("div.govuk-form-group") do
        expect(find("label.govuk-label.govuk-label--l")).to have_text "What email address did you use?"
      end
    end
  end
end
