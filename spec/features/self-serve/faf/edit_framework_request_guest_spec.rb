RSpec.feature "Editing a 'Find a Framework' request as a guest" do
  subject(:framework_request) do
    create(:framework_request, school_urn: "100253", group_uid: nil)
  end

  include_context "with schools and groups"

  before do
    visit "/procurement-support/#{framework_request.id}"
  end

  it "edit name" do
    click_link "edit-name"

    expect(page).to have_current_path "/procurement-support/#{framework_request.id}/edit?step=5"
    expect(find_field("framework-support-form-first-name-field").value).to eql "David"
    expect(find_field("framework-support-form-last-name-field").value).to eql "Georgiou"

    fill_in "framework_support_form[first_name]", with: "John"
    fill_in "framework_support_form[last_name]", with: "Smith"
    click_continue

    expect(page).to have_current_path "/procurement-support/#{framework_request.id}"

    within("dl.govuk-summary-list") do
      expect(all("dd.govuk-summary-list__value")[0]).to have_text "John Smith"
    end
  end

  it "edit email" do
    click_link "edit-email"

    expect(page).to have_current_path "/procurement-support/#{framework_request.id}/edit?step=6"
    expect(find_field("framework-support-form-email-field").value).to eql "email@example.com"

    fill_in "framework_support_form[email]", with: "john_smith@test.com"
    click_continue

    expect(page).to have_current_path "/procurement-support/#{framework_request.id}"
    within("dl.govuk-summary-list") do
      expect(all("dd.govuk-summary-list__value")[1]).to have_text "john_smith@test.com"
    end
  end

  it "edit message" do
    click_link "edit-message"

    expect(page).to have_current_path "/procurement-support/#{framework_request.id}/edit?step=7"
    expect(find_field("framework-support-form-message-body-field").value).to eql "please help!"

    fill_in "framework_support_form[message_body]", with: "I have a problem"
    click_continue

    expect(page).to have_current_path "/procurement-support/#{framework_request.id}"
    within("dl.govuk-summary-list") do
      expect(all("dd.govuk-summary-list__value")[4]).to have_text "I have a problem"
    end
  end

  describe "change organisation type and reselect", js: true do
    context "when confirmed" do
      it "saves selected organisation" do
        click_link "edit-school-type"

        expect(page).to have_current_path "/procurement-support/#{framework_request.id}/edit?step=2"
        expect(page).to have_checked_field "A single school"
        expect(page).not_to have_checked_field "An academy trust or federation"

        choose "An academy trust or federation"
        click_continue

        expect(page).to have_text "Search for an academy trust or federation"

        fill_in "framework_support_form[group_uid]", with: "2314"
        find(".autocomplete__option", text: "2314").click
        click_continue

        expect(page).to have_text "Is this the academy trust or federation you're buying for?"

        within("dl.govuk-summary-list") do
          expect(all("dd.govuk-summary-list__value")[0]).to have_text "Testing Multi Academy Trust"
        end

        choose "Yes"
        click_continue

        expect(all("dd.govuk-summary-list__value")[2]).to have_text "Testing Multi Academy Trust"
      end
    end

    context "when cancelled" do
      it "remains unchanged" do
        click_link "edit-school-type"

        expect(page).to have_current_path "/procurement-support/#{framework_request.id}/edit?step=2"
        expect(page).to have_checked_field "A single school"
        expect(page).not_to have_checked_field "An academy trust or federation"

        choose "An academy trust or federation"
        click_continue

        expect(page).to have_text "Search for an academy trust or federation"

        fill_in "framework_support_form[group_uid]", with: "2314"
        find(".autocomplete__option", text: "2314").click
        click_continue

        expect(page).to have_text "Is this the academy trust or federation you're buying for?"

        within("dl.govuk-summary-list") do
          expect(all("dd.govuk-summary-list__value")[0]).to have_text "Testing Multi Academy Trust"
        end

        choose "No"
        click_continue

        expect(find("h1.govuk-heading-l")).to have_text "Search for an academy trust or federation"
      end
    end
  end

  describe "change the selected school", js: true do
    context "when confirmed" do
      it "repopulates the field using previous search results" do
        visit "/procurement-support/new"
        choose "No, continue without a DfE Sign-in account"
        click_continue
        choose "A single school"
        click_continue

        fill_in "framework_support_form[school_urn]", with: "100253"
        find(".autocomplete__option", text: "100253").click
        click_continue

        click_on "Back"
        # "URN - NAME" recovered from session variable if available
        expect(find_field("framework-support-form-school-urn-field").value).to eql "100253 - Specialist School for Testing"
      end

      it "saves selected school" do
        click_link "edit-school"

        expect(page).to have_current_path "/procurement-support/#{framework_request.id}/edit?step=3"

        expect(find_field("framework-support-form-school-urn-field").value).to eql "100253"

        fill_in "framework_support_form[school_urn]", with: "100254"
        find(".autocomplete__option", text: "100254").click
        click_continue

        expect(page).to have_current_path "/procurement-support/#{framework_request.id}"

        expect(page).to have_text "Is this the school you're buying for?"

        within("dl.govuk-summary-list") do
          expect(all("dd.govuk-summary-list__value")[0]).to have_text "Greendale Academy for Bright Sparks"
        end

        choose "Yes"
        click_continue

        expect(all("dd.govuk-summary-list__value")[2]).to have_text "Greendale Academy for Bright Sparks"
      end
    end

    context "when cancelled" do
      it "remains unchanged" do
        click_link "edit-school"

        expect(page).to have_current_path "/procurement-support/#{framework_request.id}/edit?step=3"
        expect(find_field("framework-support-form-school-urn-field").value).to eql "100253"

        fill_in "framework_support_form[school_urn]", with: "100254"
        find(".autocomplete__option", text: "100254").click
        click_continue

        expect(page).to have_current_path "/procurement-support/#{framework_request.id}"

        expect(page).to have_text "Is this the school you're buying for?"

        within("dl.govuk-summary-list") do
          expect(all("dd.govuk-summary-list__value")[0]).to have_text "Greendale Academy for Bright Sparks"
        end

        choose "No"
        click_continue

        expect(find("h1.govuk-heading-l")).to have_text "Search for your school"
      end
    end
  end
end
