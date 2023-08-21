RSpec.feature "Editing a 'Find a Framework' request as a guest" do
  subject(:request) do
    # Specialist School for Testing
    create(:framework_request, org_id: "100253", group: false, category: catering_category)
  end

  include_context "with schools and groups"

  let(:fm_category) { create(:request_for_help_category, title: "FM", slug: "fm") }
  let(:catering_category) { create(:request_for_help_category, title: "Catering", slug: "catering", parent: fm_category) }
  let(:ict_category) { create(:request_for_help_category, title: "ICT", slug: "ict") }

  let(:keys) { all("dt.govuk-summary-list__key") }
  let(:values) { all("dd.govuk-summary-list__value") }
  let(:actions) { all("dd.govuk-summary-list__actions") }

  before do
    create(:request_for_help_category, title: "Hardware", slug: "hardware", parent: ict_category)

    visit "/procurement-support/#{request.id}"
  end

  it "goes back to the special requirements page" do
    click_on "Back"
    expect(page).to have_current_path "/procurement-support/#{request.id}/special_requirements/edit"
    expect(page).to have_text "Accessibility"
  end

  it "has submission information" do
    expect(find("h1.govuk-heading-l", text: "Send your request")).to be_present
    expect(find("p.govuk-body", text: "Once you send this request, we will review it and get in touch within 2 working days.")).to be_present
    expect(page).to have_button "Send request"
  end

  it "allows all fields to be edited" do
    expect(keys[0]).to have_text "Your name"
    expect(values[0]).to have_text "David Georgiou"
    expect(actions[0]).to have_link "Change"

    expect(keys[1]).to have_text "Your email address"
    expect(values[1]).to have_text "email@example.com"
    expect(actions[1]).to have_link "Change"

    expect(keys[2]).to have_text "Your school"
    expect(values[2]).to have_text "Specialist School for Testing"
    expect(actions[2]).to have_link "Change"

    expect(keys[3]).to have_text "School type"
    expect(values[3]).to have_text "Single"
    expect(actions[3]).to have_link "Change"

    expect(keys[4]).to have_text "Description of request"
    expect(values[4]).to have_text "please help!"
    expect(actions[4]).to have_link "Change"

    expect(keys[5]).to have_text "Type of goods or service"
    expect(values[5]).to have_text "Catering"
    expect(actions[5]).to have_link "Change"
  end

  it "edit name" do
    click_link "edit-name"

    expect(page).to have_current_path "/procurement-support/#{request.id}/name/edit"

    expect(find_field("framework-support-form-first-name-field").value).to eql "David"
    expect(find_field("framework-support-form-last-name-field").value).to eql "Georgiou"

    fill_in "framework_support_form[first_name]", with: "John"
    fill_in "framework_support_form[last_name]", with: "Smith"

    click_continue

    expect(page).to have_current_path "/procurement-support/#{request.id}"
    expect(values[0]).to have_text "John Smith"
  end

  it "edit email" do
    click_link "edit-email"

    expect(page).to have_current_path "/procurement-support/#{request.id}/email/edit"
    expect(find_field("framework-support-form-email-field").value).to eql "email@example.com"

    fill_in "framework_support_form[email]", with: "john_smith@test.com"

    click_continue

    expect(page).to have_current_path "/procurement-support/#{request.id}"
    expect(values[1]).to have_text "john_smith@test.com"
  end

  it "edit message" do
    click_link "edit-message"

    expect(page).to have_current_path "/procurement-support/#{request.id}/message/edit"

    expect(find_field("framework-support-form-message-body-field").value).to eql "please help!"

    fill_in "framework_support_form[message_body]", with: "I have a problem"

    click_continue

    expect(page).to have_current_path "/procurement-support/#{request.id}"
    expect(values[4]).to have_text "I have a problem"
  end

  describe "change organisation type and reselect", js: true do
    before do
      click_link "edit-school-type"
    end

    it "edit type" do
      expect(page).to have_current_path "/procurement-support/#{request.id}/organisation_type/edit"

      expect(page).to have_checked_field "A single school"
      expect(page).to have_unchecked_field "An academy trust or federation"
    end

    describe "and reselect organisation" do
      before do
        choose "An academy trust or federation"
        click_continue
        fill_in "framework_support_form[org_id]", with: "2314"
        find(".autocomplete__option", text: "2314").click
        click_continue
      end

      context "when confirmed" do
        it "saves selected organisation" do
          expect(find("h1.govuk-heading-l")).to have_text "Is this the academy trust or federation you're buying for?"
          expect(values[0]).to have_text "Testing Multi Academy Trust"

          choose "Yes"
          click_continue

          check "School name (select all)"
          click_continue

          choose "Yes"
          click_continue

          expect(all("dd.govuk-summary-list__value")[2]).to have_text "Testing Multi Academy Trust"
        end
      end

      context "when cancelled" do
        it "remains unchanged" do
          choose "No"
          click_continue

          expect(find("h1.govuk-heading-l")).to have_text "Search for an academy trust or federation"
        end
      end
    end
  end

  describe "change organisation (same type)", js: true do
    before do
      click_link "edit-school"
      fill_in "framework_support_form[org_id]", with: "100254"
      find(".autocomplete__option", text: "100254").click
    end

    it "goes to the school search page" do
      expect(page).to have_current_path "/procurement-support/#{request.id}/search_for_organisation/edit"
      expect(find("h1.govuk-heading-l")).to have_text "Search for your school"
    end

    it "links to the search page (other type)" do
      find("span", text: "Can't find it?").click
      click_on "Search for an academy trust or federation instead."

      expect(page).to have_current_path "/procurement-support/#{request.id}/search_for_organisation/edit?school_type=group"
      expect(find("h1.govuk-heading-l")).to have_text "Search for an academy trust or federation"
      expect(page).not_to have_text "There is a problem"
    end

    it "the confirmation page goes back to the school search page" do
      click_continue
      click_on "Back"

      expect(page).to have_title "Search for your school"
    end

    context "when confirmed" do
      it "saves selected organisation" do
        click_continue

        expect(page).to have_current_path %r{procurement-support/#{request.id}/confirm_organisation/edit}

        expect(find("h1.govuk-heading-l")).to have_text "Is this the school you're buying for?"
        expect(values[0]).to have_text "Greendale Academy for Bright Sparks"

        choose "Yes"
        click_continue

        expect(all("dd.govuk-summary-list__value")[2]).to have_text "Greendale Academy for Bright Sparks"
      end
    end

    context "when cancelled" do
      it "remains unchanged" do
        click_continue
        choose "No"
        click_continue
        expect(find("h1.govuk-heading-l")).to have_text "Search for your school"
      end
    end
  end

  describe "when changing the category" do
    before do
      click_link "edit-category"
      choose "ICT"
      click_continue
      choose "Hardware"
      click_continue
    end

    it "changes the category" do
      expect(page).to have_text "Hardware"
    end
  end
end
