RSpec.feature "Faf - dsi or search" do
  context "when the user is not signed in" do
    before do
      visit "/procurement-support/new"
    end

    it "loads the page" do
      expect(find("h1")).to have_text "Do you have a DfE Sign-in account linked to the school you're requesting support for?"
    end

    it "errors if no selection is given" do
      click_continue
      expect(find(".govuk-error-summary__body")).to have_text "Select whether you want to use a DfE Sign-in account"
    end

    xcontext "when user selects DfE Sign-in", js: true do
      before do
        find("label[for='faf-form-dsi-true-field']").click
      end

      it "makes form redirect to DfE Sign-in" do
        expect(find("form")["action"]).to match /\/auth\/dfe/
      end
    end
  end

  context "when the user is signed in" do
    before do
      user_is_signed_in
      visit "/procurement-support/new"
    end

    it "loads the page" do
      expect(find("h1")).to have_text "Do you have a DfE Sign-in account linked to the school you're requesting support for?"
    end

    it "errors if no selection is given" do
      click_continue
      expect(find(".govuk-error-summary__body")).to have_text "Select whether you want to use a DfE Sign-in account"
    end
  end
end
