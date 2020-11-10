feature "Users can see the service banners" do
  scenario "A beta phase banner helps set expectations of the service" do
    visit root_path

    expect(page).to have_content(I18n.t("banner.beta.tag"))
    expect(page).to have_content(I18n.t("banner.beta.message"))
  end
end
