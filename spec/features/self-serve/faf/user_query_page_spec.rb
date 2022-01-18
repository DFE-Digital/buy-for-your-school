RSpec.feature "Faf - how can we help?" do
  context "when the user is signed in" do
    let(:user) { create(:user) }

    before do
      user_is_signed_in(user: user)
      visit "/procurement-support/new"
      find("label", text: I18n.t("faf.dsi_or_search.radios.dsi")).click
      click_continue
      click_continue
      click_continue
      click_continue
    end

    it "loads the page" do
      expect(find("span.govuk-caption-l")).to have_text "About your request"
      expect(find("label.govuk-label--l")).to have_text "How can we help?"
      expect(find(".govuk-hint")).to have_text "Briefly describe your problem in a few sentences."
      expect(find_button("Continue")).to be_present
    end

    it "raises a validation error if no message entered" do
      click_continue

      expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
      expect(page).to have_link "You must tell us how we can help", href: "#faf-form-message-body-field-error"
      expect(find(".govuk-error-message")).to have_text "You must tell us how we can help"
    end

    it "submits a support request message" do
      fill_in "faf_form[message_body]", with: "I have a problem"
      click_continue

      expect(SupportRequest.count).to eq(1)
    end
  end

  context "when the user is not signed in" do
    before do
      visit "/procurement-support/new"
      find("label", text: I18n.t("faf.dsi_or_search.radios.no_dsi")).click
      click_continue
      click_continue
      click_continue
      click_continue
    end

    it "loads the page" do
      expect(find("span.govuk-caption-l")).to have_text "About your request"
      expect(find("label.govuk-label--l")).to have_text "How can we help?"
      expect(find(".govuk-hint")).to have_text "Briefly describe your problem in a few sentences."
      expect(find_button("Continue")).to be_present
    end

    it "raises a validation error if no message entered" do
      click_continue

      expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
      expect(page).to have_link "You must tell us how we can help", href: "#faf-form-message-body-field-error"
      expect(find(".govuk-error-message")).to have_text "You must tell us how we can help"
    end

    # TODO: to be updated when FrameworkRequest model in place
    xit "submits a support request message" do
      fill_in "faf_form[message_body]", with: "I have a problem"
      click_continue

      expect(SupportRequest.count).to eq(1)
    end
  end
end
