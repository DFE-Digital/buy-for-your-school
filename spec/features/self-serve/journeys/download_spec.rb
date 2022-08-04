RSpec.feature "Users can see their catering specification" do
  let(:user) { create(:user) }
  let(:category) { create(:category, :catering) }
  let(:journey) { create(:journey, user:, category:) }
  let(:section) { create(:section, title: "Section A", journey:) }

  before do
    user_is_signed_in(user:)
    task_radio = create(:task, title: "Radio task", section:)
    create(:step, :radio, title: "Which service do you need?", options: [{ "value" => "Catering" }], task: task_radio, order: 0)
    create(:page, title: "Next steps", slug: "next-steps-catering")
    visit "/journeys/#{journey.id}"
  end

  context "when the journey has been completed", js: true do
    scenario "HTML" do
      click_first_link_in_section_list

      choose "Catering"
      click_continue
      click_view

      expect(page).to have_breadcrumbs ["Dashboard", "Create specification", "View specification"]

      # journey.specification.header
      expect(find("h1.govuk-heading-xl")).to have_text "Your specification"

      # journey.specification.body
      expect(find("p.govuk-body", text: "Your answers have been used to create a specification, which also includes standard rules and regulations. You can go back and edit your answers if needed.")).to be_present

      # sidebar
      within ".govuk-grid-column-one-quarter" do
        expect(page).to have_link("What to do when you have completed a specification", href: "/next-steps-catering")
        expect(page).to have_link("Give feedback", href: "https://dferesearch.fra1.qualtrics.com/jfe/form/SV_2gE5Us8IIKxYge2")
      end

      click_on "Download (.docx)"

      # download page
      expect(find("h1")).to have_text "Would you like to mark this specification as 'finished' after you download the document?"
      choose "Yes"
      click_button "Save and continue"
      expect(page).to have_text "Next steps"
    end
  end

  context "when the journey has not yet been completed", js: true do
    scenario "includes an incomple warning" do
      # Omit answering a question to simulate an incomplete spec
      click_view

      # journey.specification.draft
      expect(find("strong.govuk-warning-text__text")).to have_text "You have not completed all the tasks. There may be information missing from your specification."
      click_on "Download (.docx)"
      # download page
      expect(find("h1")).to have_text "Would you like to mark this specification as 'finished' after you download the document?"
      choose "No"
      click_button "Save and continue"
      expect(find("h1.govuk-heading-xl")).to have_text "Your specification"
    end
  end
end
