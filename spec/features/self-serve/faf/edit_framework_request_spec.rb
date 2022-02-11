# TODO: - pending specs to be addressed in later FaF ticket
RSpec.feature "Edit an unsubmitted framework request" do
  before do
    create(:support_organisation, urn: "100253", name: "Specialist School for Testing")
    create(:support_organisation, urn: "100254", name: "Greendale Academy for Bright Sparks")
    create(:support_establishment_group, establishment_group_type: create(:support_establishment_group_type))
  end

  context "when user is a guest" do
    let(:framework_request) { create(:framework_request, first_name: "Bob", last_name: "Jones", school_urn: "100253", email: "email@example.com", message_body: "help!") }

    before do
      visit "/procurement-support/#{framework_request.id}"
    end

    it "allows the user to enter their name" do
      click_link "edit-name"

      expect(page).to have_current_path "/procurement-support/#{framework_request.id}/edit?step=3"
      expect(find_field("framework-support-form-first-name-field").value).to eql "Bob"
      expect(find_field("framework-support-form-last-name-field").value).to eql "Jones"

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

      expect(page).to have_current_path "/procurement-support/#{framework_request.id}/edit?step=4"
      expect(find_field("framework-support-form-email-field").value).to eql "email@example.com"

      fill_in "framework_support_form[email]", with: "john_smith@test.com"
      click_continue

      expect(page).to have_current_path "/procurement-support/#{framework_request.id}"
      within("dl.govuk-summary-list") do
        expect(all("dd.govuk-summary-list__value")[1]).to have_text "john_smith@test.com"
      end
    end

    xit "allows the user to change their selected school", js: true do
      click_link "edit-school"

      expect(page).to have_current_path "/procurement-support/#{framework_request.id}/edit?step=5"
      expect(find_field("framework-support-form-school-urn-field").value).to eql "100253"

      fill_in "framework_support_form[school_urn]", with: "100254"
      find(".autocomplete__option", text: "100254").click
      click_continue

      expect(page).to have_current_path "/procurement-support/#{framework_request.id}"
      within("dl.govuk-summary-list") do
        expect(all("dd.govuk-summary-list__value")[2]).to have_text "Greendale Academy for Bright Sparks"
      end
    end

    xit "allows the user to change their message" do
      click_link "edit-message"

      expect(page).to have_current_path "/procurement-support/#{framework_request.id}/edit?step=7"
      expect(find_field("framework-support-form-message-body-field").value).to eql "help!"

      fill_in "framework_support_form[message_body]", with: "I have a problem"
      click_continue

      expect(page).to have_current_path "/procurement-support/#{framework_request.id}"
      within("dl.govuk-summary-list") do
        expect(all("dd.govuk-summary-list__value")[4]).to have_text "I have a problem"
      end
    end
  end

  context "when user is already logged in" do
    let(:framework_request) { create(:framework_request, user: user, school_urn: "100253") }

    context "when user with one supported school" do
      let(:user) { create(:user, :one_supported_school) }

      before do
        user_is_signed_in(user: user)
        visit "/procurement-support/#{framework_request.id}"
      end

      it "does not allow to change the school" do
        within(all("div.govuk-summary-list__row")[2]) do
          expect(find("dd.govuk-summary-list__actions")).not_to have_link "Change"
        end
      end
    end

    context "when user with many supported schools" do
      let(:user) { create(:user, :many_supported_schools) }

      before do
        user_is_signed_in(user: user)
        visit "/procurement-support/#{framework_request.id}"
      end

      xit "allows the user to change the school" do
        click_link "edit-school"

        expect(page).to have_current_path "/procurement-support/#{framework_request.id}/edit?step=5"
        expect(find("input#framework-support-form-school-urn-100253-field")).to be_checked

        choose "Greendale Academy for Bright Sparks"
        click_continue

        expect(page).to have_current_path "/procurement-support/#{framework_request.id}"
        expect(all("dd.govuk-summary-list__value")[2]).to have_text "Greendale Academy for Bright Sparks"
      end
    end
  end
end
