feature "Users can see the service banners" do
  scenario "A beta phase banner helps set expectations of the service" do
    visit root_path

    expect(page).to have_content(I18n.t("banner.beta.tag"))
    expect(page.html).to include(I18n.t("banner.beta.message", support_email: ENV.fetch("SUPPORT_EMAIL")))
    expect(page).to have_content(ENV["SUPPORT_EMAIL"])
  end

  context "when the app is configured as a Contenetful preview app" do
    around do |example|
      ClimateControl.modify(
        CONTENTFUL_PREVIEW_APP: "true"
      ) do
        example.run
      end
    end

    it "renders a preview banner" do
      visit root_path

      expect(page).to have_content(I18n.t("banner.preview.tag"))
      expect(page).to have_content(I18n.t("banner.preview.message"))
    end
  end
end
