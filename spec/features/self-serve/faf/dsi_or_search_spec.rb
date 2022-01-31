RSpec.feature "Faf - dsi or search" do
  xit "has a back link to the start page" do
    visit "/procurement-support/new"
    expect(page).to have_link "Back", href: "/procurement-support"
    click_on "Back"
    expect(page).to have_current_path "/procurement-support"
  end

  xcontext "when the user is not signed in" do
    before do
      visit "/procurement-support/new"
    end

    it "loads the page" do
      expect(find("h1")).to have_text "Do you have a DfE Sign-in account linked to the school that your request is about?"
    end

    it "errors if no selection is given" do
      click_continue
      expect(find(".govuk-error-summary__body")).to have_text "Select whether you want to use a DfE Sign-in account"
    end

    context "when user selects DfE Sign-in", js: true do
      before do
        find("label", text: "Yes, use my DfE Sign-in").click
      end

      it "makes form redirect to DfE Sign-in" do
        expect(find("form")["action"]).to match(/\/auth\/dfe/)
      end
    end
  end

  xcontext "when the user is signed in" do
    before do
      user_is_signed_in
      visit "/procurement-support/new"
    end

    it "loads the page" do
      expect(find("h1")).to have_text "Do you have a DfE Sign-in account linked to the school that your request is about?"
    end

    it "errors if no selection is given" do
      click_continue
      expect(find(".govuk-error-summary__body")).to have_text "Select whether you want to use a DfE Sign-in account"
    end
  end
end
