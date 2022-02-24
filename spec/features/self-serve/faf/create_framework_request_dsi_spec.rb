RSpec.feature "Creating a 'Find a Framework' request" do
  context "when not signed in" do
    describe "the log in choice page" do
      before do
        visit "/procurement-support/new"
      end

      it "asks if a DSI account is available" do
        expect(page).to have_text "Do you have a DfE Sign-in account linked to the school that your request is about?"
      end

      it "has a back link to the start page" do
        click_on "Back"
        expect(page).to have_current_path "/procurement-support"
      end

      it "errors if no selection is made" do
        click_continue
        expect(find(".govuk-error-summary__body")).to have_text "Select whether you want to use a DfE Sign-in account"
      end

      # Javascript is used to change the form action
      context "and user selects DfE Sign-in", js: true do
        it "redirects to DSI" do
          find("label", text: "Yes, use my DfE Sign-in").click
          expect(find("form")["action"]).to match(/\/auth\/dfe/)
        end
      end
    end
  end

  context "when signed in" do
    context "and organisation can be inferred" do
      let(:user) { create(:user, :one_supported_school) }

      before do
        create(:support_organisation, urn: "100253", name: "Specialist School for Testing")
        user_is_signed_in(user: user)
        visit "/procurement-support/new"
      end

      describe "the message page" do
        it "is the only step" do
          expect(find("label.govuk-label--l")).to have_text "How can we help?"
          fill_in "framework_support_form[message_body]", with: "I have a problem"
          click_continue
          expect(find("h1.govuk-heading-l")).to have_text "Send your request"
          expect(FrameworkRequest.count).to eq(1)
        end

        it "goes back to the start page" do
          click_on "Back"
          expect(page).to have_current_path "/procurement-support"
        end

        it "validates the message exists" do
          click_continue

          expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
          expect(page).to have_link "You must tell us how we can help", href: "#framework-support-form-message-body-field-error"
          expect(find(".govuk-error-message")).to have_text "You must tell us how we can help"
        end
      end
    end

    context "and organisation cannot be inferred" do
      include_context "with schools and groups"

      before do
        user_is_signed_in(user: user)
        visit "/procurement-support/new"
      end

      it "lists all supported schools and groups" do
        expect(find("span.govuk-caption-l")).to have_text "About your school"
        expect(find("legend.govuk-fieldset__legend")).to have_text "Which school are you buying for?"
        expect(page).to have_unchecked_field "Specialist School for Testing"
        expect(page).to have_unchecked_field "Greendale Academy for Bright Sparks"
        expect(page).to have_unchecked_field "Testing Multi Academy Trust (MAT)"
        expect(page).to have_unchecked_field "New Academy Trust (MAT)"
      end

      it "validates a group or school is selected" do
        click_continue
        within "div.govuk-error-summary" do
          expect(page).to have_text "Select the school or group you want help buying for"
        end
      end

      it "proceeds to the message page" do
        choose "Greendale Academy for Bright Sparks"
        click_continue
        expect(find("span.govuk-caption-l")).to have_text "About your request"
      end
    end
  end
end
