RSpec.feature "Edit an unsubmitted framework request" do
  context "user is a guest" do
    let(:framework_request) { create(:framework_request, school_urn: "urn-type-1") }
    before do
      visit "/procurement-support/#{framework_request.id}"
    end

    it "allows the user to enter their name" do
      click_link "edit-name"

      expect(page).to have_current_path "/procurement-support/#{framework_request.id}/edit?step=2"
      # expect(find("textarea.govuk-textarea")).to have_text ""

      fill_in "framework_support_form[first_name]", with: "John"
      fill_in "framework_support_form[last_name]", with: "Smith"
      click_continue

      expect(page).to have_current_path "/procurement-support/#{framework_request.id}"
    
      within("dl.govuk-summary-list") do
        expect(all("dd.govuk-summary-list__value")[0]).to have_text "John Smith"
      end
    end

    it "allows the user to enter their email" do
      click_link "edit-email"

      expect(page).to have_current_path "/procurement-support/#{framework_request.id}/edit?step=3"
      # expect(find("textarea.govuk-textarea")).to have_text "email@example.com"

      fill_in "framework_support_form[email]", with: "john_smith@test.com"
      click_continue

      expect(page).to have_current_path "/procurement-support/#{framework_request.id}"
      within("dl.govuk-summary-list") do
        expect(all("dd.govuk-summary-list__value")[1]).to have_text "john_smith@test.com"
      end
    end

    xit "allows the user to change their selected school", js: true do
      click_link "edit-school"

      expect(page).to have_current_path "/procurement-support/#{framework_request.id}/edit?step=4"
      # expect(find("textarea.govuk-textarea")).to have_text ""

      fill_in "framework_support_form[school_urn]", with: "100253"
      # TODO: click first option in drop down
      click_link "framework-support-form-school-urn-field__option--0"
      click_continue

      expect(page).to have_current_path "/procurement-support/#{framework_request.id}"
      within("dl.govuk-summary-list") do
        expect(all("dd.govuk-summary-list__value")[2]).to have_text "Jubilee Primary School"
      end
    end

    it "allows the user to change their message" do
      click_link "edit-message"

      expect(page).to have_current_path "/procurement-support/#{framework_request.id}/edit?step=5"
      # expect(find("textarea.govuk-textarea")).to have_text "please help!"

      fill_in "framework_support_form[message_body]", with: "I have a problem"
      click_continue

      expect(page).to have_current_path "/procurement-support/#{framework_request.id}"
      within("dl.govuk-summary-list") do
        expect(all("dd.govuk-summary-list__value")[3]).to have_text "I have a problem"
      end
    end
  end

  context "user is already logged in" do
    let(:framework_request) { create(:framework_request, user: user, school_urn: "urn-type-1") }
  
    context "when user with one supported school" do
      let(:user) { create(:user, :one_supported_school) }

      before do
        user_is_signed_in(user: user)
        visit "/procurement-support/#{framework_request.id}"
      end

      it "does not allow to change the school" do
        # binding.pry
        within(all("div.govuk-summary-list__row")[2]) do
          expect(find("dd.govuk-summary-list__actions")).not_to have_link "Change"
        end
      end
    end

    context "when user with many supported schools" do
      let(:user) { create(:user, :many_supported_schools) }

      before do
        create(:support_organisation, urn: "urn-type-1", name: "School #1")
        create(:support_organisation, urn: "greendale-urn", name: "Greendale Academy for Bright Sparks")
        user_is_signed_in(user: user)
        visit "/procurement-support/#{framework_request.id}"
      end

      it "allows the user to change the school" do
        click_link "edit-school"

        expect(page).to have_current_path "/procurement-support/#{framework_request.id}/edit?step=4"
        pp page.source
        expect(find("input#faf-form-school-urn-urn-type-1-field")).to be_checked

        choose "Greendale Academy for Bright Sparks"
        click_continue

        expect(page).to have_current_path "/procurement-support/#{framework_request.id}"
        expect(all("dd.govuk-summary-list__value")[2]).to have_text "Greendale Academy for Bright Sparks"
      end
    end
  end
end