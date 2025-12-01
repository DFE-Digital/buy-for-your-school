RSpec.feature "User feedback page" do
  before do
    visit "/feedback/new"
  end

  describe "navigate to the feedback page" do
    context "when a user selects the feedback link in the page header" do
      it "displays the feedback page" do
        expect(page).to have_breadcrumbs ["Dashboard", "Give feedback"]
        expect(find("h1.govuk-heading-xl")).to have_text "Give feedback on Get help buying for schools"
        expect(find("h1.govuk-fieldset__heading")).to have_text "Satisfaction survey"
        expect(find("legend.govuk-fieldset__legend--s")).to have_text "Overall, how did you feel about the service you received today?"

        expect(page).to have_unchecked_field "Very satisfied"
        expect(page).to have_unchecked_field "Satisfied"
        expect(page).to have_unchecked_field "Neither satisfied or dissatisfied"
        expect(page).to have_unchecked_field "Dissatisfied"
        expect(page).to have_unchecked_field "Very dissatisfied"

        expect(find("label.govuk-label--s")).to have_text "How could we improve this service? (Optional)"
        expect(find("div.govuk-hint")).to have_text "Do not include personal or financial information, for example your National Insurance or credit card numbers."
        expect(page).to have_button "Submit"
      end
    end
  end

  describe "error message" do
    context "when a user has not selected a satisfaction rating" do
      before do
        click_on "Submit"
      end

      it "displays an error message" do
        expect(page).to have_text "Select how you feel about the service you received"
      end
    end
  end

  describe "feedback data is persisted" do
    context "when a user fills out the form" do
      before do
        choose "Very satisfied"
        fill_in "feedback_form[feedback_text]", with: "test"
        click_on "Submit"
      end

      it "stores their feedback" do
        feedback = UserFeedback.first
        expect(feedback.service).to eq "create_a_specification"
        expect(feedback.satisfaction).to eq "very_satisfied"
        expect(feedback.feedback_text).to eq "test"
        expect(feedback.logged_in).to eq false
      end

      it "navigates to the feedback confirmation page" do
        expect(page).to have_breadcrumbs ["Dashboard", "Give feedback"]
        expect(find("h1.govuk-panel__title", text: "Feedback submitted")).to be_present
        expect(find("p.govuk-body", text: "We will use your feedback to improve this service.")).to be_present
        expect(find("h2.govuk-heading-m", text: "Get involved")).to be_present
        expect(find("p.govuk-body", text: "Help us improve this service by opting in to take part in user research.")).to be_present
        feedback = UserFeedback.last
        expect(page).to have_link "Help us improve this service", href: "/feedback/#{feedback.id}/edit", class: "govuk-link"
      end
    end
  end
end
