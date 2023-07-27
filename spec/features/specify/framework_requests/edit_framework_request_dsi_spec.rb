RSpec.feature "Editing a 'Find a Framework' request as a user" do
  subject(:request) do
    # Specialist School for Testing
    create(:framework_request, user:, org_id: "100253", group: false)
  end

  include_context "with schools and groups"

  let(:keys) { all("dt.govuk-summary-list__key") }
  let(:values) { all("dd.govuk-summary-list__value") }
  let(:actions) { all("dd.govuk-summary-list__actions") }

  before do
    user_is_signed_in(user:)
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

  it "only allows some fields to be edited" do
    expect(keys[0]).to have_text "Your name"
    expect(values[0]).to have_text "first_name last_name"
    expect(actions[0]).not_to have_link "Change"

    expect(keys[1]).to have_text "Your email address"
    expect(values[1]).to have_text "test@test"
    expect(actions[1]).not_to have_link "Change"

    expect(keys[2]).to have_text "Your school"
    expect(values[2]).to have_text "Specialist School for Testing"
    expect(actions[2]).to have_link "Change"

    expect(keys[3]).to have_text "School type"
    expect(values[3]).to have_text "Single"
    expect(actions[3]).not_to have_link "Change"

    expect(keys[4]).to have_text "Description of request"
    expect(values[4]).to have_text "please help!"
    expect(actions[4]).to have_link "Change"
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

  context "with many supported schools and groups", js: true do
    it "the school or group can be edited" do
      click_link "edit-school"

      expect(page).to have_current_path "/procurement-support/#{request.id}/select_organisation/edit"
      expect(all(".govuk-radios__item").count).to be 4

      expect(page).to have_checked_field "Specialist School for Testing"

      expect(page).to have_unchecked_field "Greendale Academy for Bright Sparks"
      expect(page).to have_unchecked_field "Testing Multi Academy Trust (MAT)"
      expect(page).to have_unchecked_field "New Academy Trust (MAT)"

      choose "Testing Multi Academy Trust (MAT)"
      click_continue

      expect(page).to have_current_path "/procurement-support/#{request.id}"

      expect(values[2]).to have_text "Testing Multi Academy Trust"

      click_link "edit-school"

      expect(page).to have_checked_field "Testing Multi Academy Trust (MAT)"

      expect(page).to have_unchecked_field "Specialist School for Testing"
      expect(page).to have_unchecked_field "Greendale Academy for Bright Sparks"
      expect(page).to have_unchecked_field "New Academy Trust (MAT)"
    end
  end

  context "with one supported school" do
    let(:user) { create(:user, :one_supported_school) }

    it "the school can not be edited" do
      expect(actions[2]).not_to have_link "Change"
    end
  end
end
