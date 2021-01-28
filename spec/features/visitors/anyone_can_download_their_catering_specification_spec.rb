feature "Users can see their catering specification" do
  scenario "HTML" do
    stub_contentful_category(fixture_filename: "category-with-liquid-template.json")
    visit root_path
    click_on(I18n.t("generic.button.start"))

    click_first_link_in_task_list

    choose("Catering")

    click_on(I18n.t("generic.button.next"))

    expect(page).to have_content(I18n.t("journey.specification.header"))

    click_on("Download (.docx)")

    expect(page.response_headers["Content-Type"]).to eql("application/vnd.openxmlformats-officedocument.wordprocessingml.document")
    header = page.response_headers["Content-Disposition"]
    expect(header).to match(/^attachment/)
    expect(header).to match(/filename="specification.docx"/)
  end
end
