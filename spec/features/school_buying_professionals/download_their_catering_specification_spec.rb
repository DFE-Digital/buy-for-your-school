feature "Users can see their catering specification" do
  before { user_is_signed_in }

  context "when the journey has been completed" do
    scenario "HTML" do
      start_journey_from_category_and_go_to_first_section(category: "category-with-liquid-template.json")

      common_specification_html = "<article id='specification'><h1>Liquid </h1></article>"
      expect(Htmltoword::Document)
        .to receive(:create)
        .with(common_specification_html, nil, false)
        .and_call_original

      choose("Catering")

      click_on(I18n.t("generic.button.next"))

      click_on(I18n.t("journey.specification.button"))

      expect(page).to have_content(I18n.t("journey.specification.header"))

      click_on("Download (.docx)")

      expect(page.response_headers["Content-Type"]).to eql("application/vnd.openxmlformats-officedocument.wordprocessingml.document")
      header = page.response_headers["Content-Disposition"]
      expect(header).to match(/^attachment/)
      expect(header).to match(/filename="specification.docx"/)
    end
  end

  context "when the journey has not yet been completed" do
    scenario "includes an incomple warning" do
      start_journey_from_category(
        category: "category-with-liquid-template.json"
      )

      # Omit answering a question to simulate an incomplete spec

      click_on(I18n.t("journey.specification.button"))

      warning_html = I18n.t("journey.specification.download.warning.incomplete")
      common_specification_html = "<article id='specification'><h1>Liquid </h1></article>"
      expect(page).not_to have_content(Nokogiri::HTML(warning_html).text)
      expect(Htmltoword::Document)
        .to receive(:create)
        .with(common_specification_html.prepend(warning_html), nil, false)
        .and_call_original

      click_on("Download (.docx)")

      expect(page.response_headers["Content-Disposition"]).to match(/filename="specification-incomplete.docx"/)
    end
  end
end
