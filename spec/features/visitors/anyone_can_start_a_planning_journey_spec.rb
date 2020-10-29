feature "Anyone can start the planning journey" do
  scenario "Start page includs a call to action" do
    visit root_path

    click_on(I18n.t("generic.button.start"))

    expect(page).to have_content("Which service do you need?")
    expect(page).to have_content("Tell us which service you need.")
    expect(page).to have_content("Catering")
    expect(page).to have_content("Cleaning")

    choose("Catering")

    click_on(I18n.t("generic.button.soft_finish"))
  end
end
