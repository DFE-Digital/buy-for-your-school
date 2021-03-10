feature "Users can see their catering specification" do
  scenario "HTML" do
    start_journey_from_category_and_go_to_question(category: "category-with-liquid-template.json")

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
