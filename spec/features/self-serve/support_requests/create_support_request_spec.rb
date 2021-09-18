RSpec.feature "Create a new support request" do
  before do
    travel_to Time.zone.local(2021, 9, 1, 0o1, 0o4, 44)
  end

  before do
    user_is_signed_in
    visit "/support-requests"
  end

  specify { expect(page).to have_current_path "/support-requests" }


  it "support_requests.start.h1_heading" do
    expect(find("h1.govuk-heading-xl")).to have_text "Request help and support with your specification"
  end

  it "explains the form to the user" do
    expect(page).to have_text "Use this service to request free advice and support from our procurement experts for help with your catering or multi-functional devices specification."
    expect(page).to have_text "DfE's supported buying team will respond to you within 5 working days."
  end

  it "links to more information" do
    expect(page).to have_link "read about writing a specification",
                              href: "https://www.gov.uk/guidance/buying-procedures-and-procurement-law-for-schools/writing-a-specification",
                              class: "govuk-link"

    expect(page).to have_link "planning for what you're buying",
                              href: "https://www.gov.uk/guidance/buying-for-schools",
                              class: "govuk-link"

    expect(page).to have_link "information on finding the right way to buy",
                              href: "https://www.gov.uk/guidance/buying-procedures-and-procurement-law-for-schools",
                              class: "govuk-link"

    expect(page).to have_link "find a framework service",
                              href: "https://www.gov.uk/guidance/find-a-dfe-approved-framework-for-your-school",
                              class: "govuk-link"
  end

  it "generic.button.start" do
    expect(find("a.govuk-button")).to have_text "Start"
    expect(find("a.govuk-button")[:role]).to eq "button"
  end

  describe "About you" do
    it "confirms contact information" do
      click_on "Start"

      expect(find("span.govuk-caption-l")).to have_text "About you"
      expect(find("h1.govuk-heading-l")).to have_text "Is this your contact information?"
      expect(find("a.govuk-button")).to have_text "Yes, continue"

      expect(page).to have_link "Exit without saving", href: "/dashboard"
    end
  end













  context "without an existing spec" do


  end




  context "with an existing spec" do
    before do
      journey = create(:journey)
      user_is_signed_in(user: journey.user)
      visit "/support-requests"
    end

    describe "a completed validated form" do
      it "can be submitted" do
        expect(page).to have_current_path "/support-requests"
        click_on "Start"

        expect(page).to have_current_path "/profile"
        click_on "Yes, continue"

        expect(page).to have_current_path "/support-requests/new"
        expect(find("label.govuk-label--l")).to have_text "What is your phone number?"

        # validate presence of phone number
        click_continue
        expect(find("span.govuk-error-message")).to have_text "can't be blank"

        fill_in "support_form[phone_number]", with: "0151 000 0000"
        click_continue

binding.pry
        expect(page).to have_current_path "/support-requests"
        # expect(find("label.govuk-label--l")).to have_text "Which of your specifications are related to this request?"
        # expect(page).to have_link "My request is not related to a specification I've created", href: "/", class: "govuk-link"

        choose "1 September 2021"
        click_continue

        expect(find("label.govuk-label--l")).to have_text "What are you buying?"

        choose "category title"
        click_continue

        expect(find("label.govuk-label--l")).to have_text "How can we help?"

        fill_in "support_form[message]", with: "This is my long answer"
        click_continue

        expect(find("div#flash_notice")).to have_text "Support request created"
      end
    end
  end
end
