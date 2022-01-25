RSpec.feature "Faf - how can we help?" do
  context "when the user is signed in" do
    let(:user) { create(:user, :one_supported_school) }

    before do
      user_is_signed_in(user: user)
      visit "/procurement-support/new"
      find("label", text: "Yes, use my DfE Sign-in").click
      click_continue
      click_continue
      click_continue
    end

    it "loads the page" do
      expect(find("span.govuk-caption-l")).to have_text "About your request"
      expect(find("label.govuk-label--l")).to have_text "How can we help?"
      expect(find(".govuk-hint")).to have_text "Briefly describe what advice or guidance you need in a few sentences."
      expect(find_button("Continue")).to be_present
    end

    it "has a back link to step 3" do
      click_on "Back"
      expect(page).to have_current_path "/procurement-support?faf_form%5Bback%5D=true&faf_form%5Bdsi%5D=true&faf_form%5Bmessage_body%5D=&faf_form%5Bschool_urn%5D=urn-type-1&faf_form%5Bstep%5D=4"
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

      expect(FrameworkRequest.count).to eq(1)
    end
  end

  xcontext "when the user is not signed in" do
    before do
      visit "/procurement-support/new"
      find("label", text: "No, continue without a DfE Sign-in account").click
      click_continue
      click_continue
      click_continue
    end

    it "loads the page" do
      expect(find("span.govuk-caption-l")).to have_text "About your request"
      expect(find("label.govuk-label--l")).to have_text "How can we help?"
      expect(find(".govuk-hint")).to have_text "Briefly describe what advice or guidance you need in a few sentences."
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

      expect(FrameworkRequest.count).to eq(1)
    end
  end
end
