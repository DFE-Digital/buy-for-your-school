# TODO: replace with shared context journey factories
RSpec.feature "Users can see their catering specification" do
  before do
    user_is_signed_in
    start_journey_from_category(category: "category-with-liquid-template.json")
  end

  context "when the journey has been completed" do
    scenario "HTML" do
      click_first_link_in_section_list

      choose "Catering"
      click_continue
      click_view

      expect(page).to have_breadcrumbs ["Dashboard", "Create specification", "View specification"]

      # journey.specification.header
      expect(find("h1.govuk-heading-xl")).to have_text "Your specification"

      # journey.specification.body
      expect(find("p.govuk-body")).to have_text "Your answers have been used to create a specification, which also includes standard rules and regulations. You can go back and edit your answers if needed."

      # journey.specification.download.button
      expect(find("a.govuk-button:contains('Download (.docx)')")[:href]).to include "specification.docx"

      within "article.specification" do
        # journey.specification.next_steps
        expect(page).to have_text("Once you have a completed specification,")
        expect(page).to have_link("see what the next steps are.", href: "/next-steps-catering")
        # journey.specification.feedback.heading
        expect(page).to have_text "Giving us feedback"
        # journey.specification.feedback.body
        expect(page).to have_text "Tell us how Get Help Buying for Schools is working for you."
        # journey.specification.feedback.button
        expect(page).to have_link("Give feedback (opens in a new tab)", href: "https://dferesearch.fra1.qualtrics.com")
        # ensure button opens in new tab
        expect(find("a.govuk-button:contains('Give feedback (opens in a new tab)')")[:target]).to eq "_blank"
      end

      click_on "Download (.docx)"

      expect(page.response_headers["Content-Type"]).to eql "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      expect(page.response_headers["Content-Disposition"]).to match(/^attachment/)
      expect(page.response_headers["Content-Disposition"]).to match(/filename="specification.docx"/)
    end
  end

  context "when the journey has not yet been completed" do
    scenario "includes an incomple warning" do
      # Omit answering a question to simulate an incomplete spec
      click_view

      # journey.specification.draft
      expect(find("strong.govuk-warning-text__text")).to have_text "You have not completed all the tasks. Your specification is incomplete."

      click_on "Download (.docx)"

      expect(page.response_headers["Content-Disposition"]).to match(/filename="specification-incomplete.docx"/)
    end
  end
end
