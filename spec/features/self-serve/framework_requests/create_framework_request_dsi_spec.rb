RSpec.feature "Creating a 'Find a Framework' request" do
  context "when not signed in" do
    describe "the log in choice page" do
      before do
        visit "/procurement-support/sign_in"
      end

      it "asks if a DSI account is available" do
        expect(page).to have_text "Do you have a DfE Sign-in account linked to the school that your request is about?"
      end

      it "has a back link to the start page" do
        click_on "Back"
        expect(page).to have_current_path "/procurement-support"
      end

      it "validates a choice is made" do
        click_continue

        expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
        expect(page).to have_link "Select whether you want to use a DfE Sign-in account", href: "#framework-support-form-dsi-field-error"
      end

      it "allows the use of DSI" do
        expect(find("label", text: "Yes, use my DfE Sign-in")).to be_present
      end
    end
  end

  context "when signed in" do
    context "and organisation can be inferred" do
      let(:user) { create(:user, :one_supported_school) }

      before do
        create(:support_organisation, urn: "100253", name: "Specialist School for Testing")
        user_is_signed_in(user:)
        visit "/procurement-support/confirm_sign_in"
        click_on "Yes, continue"
      end

      describe "CYA page" do
        before do
          fill_in "framework_support_form[message_body]", with: "I have a problem"
          click_continue
          click_continue
          choose "Confident"
          click_continue
          choose "No"
          click_continue
        end

        it "shows the inferred organisation" do
          expect(page).to have_text "Specialist School for Testing"
        end
      end

      describe "the message page" do
        it "goes back to the start page" do
          click_on "Back"
          expect(page).to have_current_path "/procurement-support"
        end

        it "validates the message exists" do
          click_continue

          expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
          expect(page).to have_link "You must tell us how we can help", href: "#framework-support-form-message-body-field-error"
        end
      end

      describe "the special requirements page" do
        before do
          fill_in "framework_support_form[message_body]", with: "I have a problem"
          click_continue
          click_continue
          choose "Confident"
          click_continue
        end

        it "is the last step" do
          expect(page).to have_text "Special requirements"
          choose "Yes"
          fill_in "What are your requirements?", with: "My requirements"
          click_continue
          expect(page).to have_text "Send your request"
          expect(FrameworkRequest.count).to eq(1)
        end
      end
    end

    context "and organisation cannot be inferred" do
      include_context "with schools and groups"

      before do
        user_is_signed_in(user:)
        visit "/procurement-support/select_organisation"
      end

      it "lists all supported schools and groups" do
        expect(find("span.govuk-caption-l")).to have_text "About your school"
        expect(find("legend.govuk-fieldset__legend")).to have_text "Which school are you buying for?"

        expect(all(".govuk-radios__item").count).to be 4

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

      context "when the school or group needs to be changed" do
        it "goes back so a different school or group can be selected" do
          # 1. select school
          choose "Greendale Academy for Bright Sparks"
          click_continue
          click_on "Back"
          expect(page).to have_checked_field "Greendale Academy for Bright Sparks"

          expect(page).to have_unchecked_field "Specialist School for Testing"
          expect(page).to have_unchecked_field "Testing Multi Academy Trust (MAT)"
          expect(page).to have_unchecked_field "New Academy Trust (MAT)"

          # 2. select group
          choose "New Academy Trust (MAT)"
          click_continue
          click_on "Back"
          expect(page).to have_checked_field "New Academy Trust (MAT)"

          expect(page).to have_unchecked_field "Greendale Academy for Bright Sparks"
          expect(page).to have_unchecked_field "Specialist School for Testing"
          expect(page).to have_unchecked_field "Testing Multi Academy Trust (MAT)"

          # 3. select different school
          choose "Specialist School for Testing"
          click_continue
          click_on "Back"

          expect(page).to have_checked_field "Specialist School for Testing"

          expect(page).to have_unchecked_field "Greendale Academy for Bright Sparks"
          expect(page).to have_unchecked_field "Testing Multi Academy Trust (MAT)"
          expect(page).to have_unchecked_field "New Academy Trust (MAT)"
        end
      end
    end
  end
end
