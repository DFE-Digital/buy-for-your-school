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

      # journey.specification.download.button
      expect(find("a.govuk-button")).to have_text "Download (.docx)"
      expect(find("a.govuk-button")[:role]).to eq "button"

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

      warning_html = I18n.t("journey.specification.download.warning.incomplete")
      expect(page).not_to have_content(Nokogiri::HTML(warning_html).text)

      click_on "Download (.docx)"

      expect(page.response_headers["Content-Disposition"]).to match(/filename="specification-incomplete.docx"/)
    end
  end
end
