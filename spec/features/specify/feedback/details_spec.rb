RSpec.feature "User feedback details" do
  let(:feedback) { UserFeedback.first }

  describe "Function" do
    context "when not logged in" do
      it "persists the user's details" do
        feedback_user_details

        expect(feedback.full_name).to eq "Dave Georgiou"
        expect(feedback.email).to eq "dave@dave.com"
        expect(feedback.logged_in).to be false
        expect(feedback.logged_in_as).to be_nil
      end
    end

    context "when logged in" do
      let(:user) { create(:user) }

      it "persists the user's details and loggged in status" do
        user_is_signed_in(user:)
        feedback_user_details

        expect(feedback.full_name).to eq "Dave Georgiou"
        expect(feedback.email).to eq "dave@dave.com"
        expect(feedback.logged_in).to be true
        expect(feedback.logged_in_as_id).to eq user.id
      end
    end

    def feedback_user_details
      visit "/feedback/new"
      choose "Very satisfied"
      click_on "Submit"
      click_link "Help us improve this service"
      fill_in "feedback_form[full_name]", with: "Dave Georgiou"
      fill_in "feedback_form[email]", with: "dave@dave.com"
      click_on "Submit"
    end
  end

  describe "Pages" do
    let(:feedback) { create(:user_feedback) }

    before do
      visit "/feedback/#{feedback.id}/edit"
    end

    it "displays the feedback user details edit page" do
      expect(page).to have_breadcrumbs ["Dashboard", "Get involved"]
      expect(find("h1.govuk-heading-l")).to have_text "Enter your contact details"
      expect(find("p.govuk-body-m")).to have_text "Give your details to opt-in and take part in user research to help us improve the service. We will not use your details for any other purpose."
      expect(all("label")[0]).to have_text "Full name"
      expect(all("label")[1]).to have_text "Email"
      expect(page).to have_button "Submit"
    end

    context "with completed user details" do
      before do
        feedback.update!(full_name: "dave", email: "dave@dave.com")
        visit "/feedback/#{feedback.id}"
      end

      it "displays the success page" do
        expect(page).to have_breadcrumbs ["Dashboard", "Get involved"]
        expect(page).to have_content "Confirmation"
        expect(find("p.govuk-body", text: "Thank you for opting in to take part in user research.")).to be_present
        expect(page).to have_content "What happens next"
        expect(find("p.govuk-body", text: "We will contact you via email and invite you to take part in research when it becomes available.")).to be_present
        expect(page).to have_link "Go to Find an approved framework", href: "https://www.gov.uk/guidance/find-a-dfe-approved-framework-for-your-school", class: "govuk-link"
      end
    end
  end

  describe "Error messages" do
    let(:feedback) { create(:user_feedback) }

    before do
      visit "/feedback/#{feedback.id}/edit"
    end

    context "when full name is not given" do
      before do
        fill_in "feedback_form[email]", with: "email@email.com"
        click_on "Submit"
      end

      it "displays an error message" do
        expect(find(".govuk-error-summary")).to have_text "Enter your full name"
      end
    end

    context "when email is not given" do
      before do
        fill_in "feedback_form[full_name]", with: "name"
        click_on "Submit"
      end

      it "displays an error message" do
        expect(find(".govuk-error-summary")).to have_text "Enter an email in the correct format. For example, 'someone@school.sch.uk'"
      end
    end

    context "when email is formatted incorrectly" do
      before do
        fill_in "feedback_form[email]", with: "email"
        click_on "Submit"
      end

      it "displays an error message" do
        expect(find(".govuk-error-summary")).to have_text "Enter an email in the correct format. For example, 'someone@school.sch.uk'"
      end
    end
  end
end
