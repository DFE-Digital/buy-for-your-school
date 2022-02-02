RSpec.feature "Create a new framework request" do
  context "when user with one supported school", js: true do
    let(:user) { create(:user, :one_supported_school, first_name: "Generic", last_name: "User", full_name: "Generic User") }

    before do
      create(:support_organisation, urn: "100253", name: "School #1")
      stub_request(:post, "https://api.notifications.service.gov.uk/v2/notifications/email")
      .to_return(body: {}.to_json, status: 200, headers: {})
    end

    context "when user is already signed in" do
      let(:answers) { find_all("dd.govuk-summary-list__value") }

      before do
        user_is_signed_in(user: user)
        visit "/procurement-support"
      end

      it "loads the start page" do
        expect(page).to have_current_path "/procurement-support"
      end

      it "skips user straight to how can we help page" do
        find("a", text: "Start now").click
        expect(find("label.govuk-label--l")).to have_text "How can we help?"
        expect(page).to have_current_path "/procurement-support/new"
      end

      it "navigates to check answers page from how we can help" do
        # test coverage for this form needs an org factory
        find("a", text: "Start now").click
        fill_in "framework_support_form[message_body]", with: "I have a problem"
        click_continue
        expect(answers[3]).to have_text "I have a problem"
      end

      it "navigates to confirmation page upon sending request" do
        find("a", text: "Start now").click
        fill_in "framework_support_form[message_body]", with: "I have a problem"
        click_continue
        click_button "Send request"
        expect(find("h1.govuk-panel__title")).to have_text "Your request for support has been sent"
      end
    end

    context "when user is not already signed in" do
      before do
        visit "/procurement-support"
      end

      describe "start page" do
        it "loads the page" do
          expect(find("h1")).to have_text "Request advice and guidance for your procurement"
          expect(page).to have_current_path "/procurement-support"
        end

        it "navigates to the about frameworks page in an external tab" do
          url = "https://www.gov.uk/guidance/buying-procedures-and-procurement-law-for-schools/find-the-right-way-to-buy"
          expect(page).to have_link_to_open_in_new_tab("about frameworks", href: url)
        end

        it "navigates to the planning for what you're buying page in an external tab" do
          url = "https://www.gov.uk/guidance/buying-for-schools"
          expect(page).to have_link_to_open_in_new_tab("planning for what you're buying", href: url)
        end

        it "navigates to the finding the right way to buy page in an external tab" do
          url = "https://www.gov.uk/guidance/buying-procedures-and-procurement-law-for-schools"
          expect(page).to have_link_to_open_in_new_tab("finding the right way to buy", href: url)
        end

        it "navigates to the create a specification page directly as an internal link" do
          expect(page).to have_link "create a specification", href: "/", class: "govuk-link"
        end
      end

      describe "dsi sign in page" do
        before do
          visit "/procurement-support/new"
        end

        it "has a back link to the start page" do
          click_on "Back"
          expect(page).to have_current_path "/procurement-support"
        end

        it "loads the page" do
          expect(page).to have_text "Do you have a DfE Sign-in account linked to the school that your request is about?"
        end

        it "errors if no selection is given" do
          click_continue
          expect(find(".govuk-error-summary__body")).to have_text "Select whether you want to use a DfE Sign-in account"
        end

        context "when user selects DfE Sign-in", js: true do
          before do
            find("label", text: "Yes, use my DfE Sign-in").click
          end

          it "makes form redirect to DfE Sign-in" do
            expect(find("form")["action"]).to match(/\/auth\/dfe/)
          end
        end
      end
      # passing

      describe "contact info page", js: true do
        before do
          user_exists_in_dfe_sign_in(user: user)
          visit "/procurement-support/new"
          choose "Yes, use my DfE Sign-in"
          click_continue
        end

        it "displays the correct attributes on the page" do
          # pp page.source
          expect(find("span.govuk-caption-l")).to have_text "About you"
          expect(find("h1.govuk-heading-l")).to have_text "Is this your contact information?"
          expect(all("p")[1]).to have_text "These are the details we have for you, if they are not correct or up to date you will need to either:"

          within("ul.govuk-list") do
            # pp page.source
            expect(all("li")[0]).to have_text "log back in with the correct account"
            expect(all("li")[1]).to have_link "update your DfE Sign In account details", href: "https://test-profile.signin.education.gov.uk/edit-details", class: "govuk-link"
          end

          within("dl.govuk-summary-list") do
            expect(all("dt")[0]).to have_text "Your name"
            expect(all("dd")[0]).to have_text "Generic User"
            expect(all("dt")[1]).to have_text "Your email address"
            expect(all("dd")[1]).to have_text "test@test"
          end

          expect(find("a.govuk-button")).to have_text "Yes, continue"
        end
      end

      describe "user organisation page" do
        before do
          user_exists_in_dfe_sign_in(user: user)
          visit "/procurement-support/new"
          choose "Yes, use my DfE Sign-in"
          click_continue
          click_continue
        end

        it "skips step 3 because the school is implicit" do
          expect(page).not_to have_unchecked_field "Specialist School for Testing"
          expect(find("span.govuk-caption-l")).to have_text "About your request"
        end
      end

      describe "user query page" do
        before do
          user_exists_in_dfe_sign_in(user: user)
          visit "/procurement-support/new"
          find("label", text: "Yes, use my DfE Sign-in").click
          click_continue
          click_continue
        end

        it "has a back link to step 3" do
          click_on "Back"
          expect(page).to have_current_path "/procurement-support"
        end

        it "raises a validation error if no message entered" do
          click_continue

          expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
          expect(page).to have_link "You must tell us how we can help", href: "#framework-support-form-message-body-field-error"
          expect(find(".govuk-error-message")).to have_text "You must tell us how we can help"
        end

        it "submits a support request message" do
          # pp page.source
          fill_in "framework_support_form[message_body]", with: "I have a problem"
          click_continue

          expect(FrameworkRequest.count).to eq(1)
        end
      end

      describe "check answers page" do
        before do
          # create(:support_organisation, urn: "urn-type-1", name: "School #1")
          user_exists_in_dfe_sign_in(user: user)
          visit "/procurement-support/new"
          find("label", text: "Yes, use my DfE Sign-in").click
          click_continue
          click_continue
          fill_in "framework_support_form[message_body]", with: "I have a problem"
          click_continue
        end

        it "shows the CYA page" do
          expect(find("h1.govuk-heading-l")).to have_text "Send your request"
          within("dl.govuk-summary-list") do
            expect(all("dt.govuk-summary-list__key")[0]).to have_text "Your name"
            expect(all("dd.govuk-summary-list__value")[0]).to have_text "Generic User"
            expect(all("dd.govuk-summary-list__actions")[0]).not_to have_link "Change"

            expect(all("dt.govuk-summary-list__key")[1]).to have_text "Your email address"
            expect(all("dd.govuk-summary-list__value")[1]).to have_text "test@test"
            expect(all("dd.govuk-summary-list__actions")[1]).not_to have_link "Change"

            expect(all("dt.govuk-summary-list__key")[2]).to have_text "Your school"
            expect(all("dd.govuk-summary-list__value")[2]).to have_text "School #1"
            expect(all("dd.govuk-summary-list__actions")[2]).not_to have_link "Change"

            expect(all("dt.govuk-summary-list__key")[3]).to have_text "Description of request"
            expect(all("dd.govuk-summary-list__value")[3]).to have_text "I have a problem"
            expect(all("dd.govuk-summary-list__actions")[3]).to have_link "Change"
          end
          expect(find("p.govuk-body")).to have_text "Once you send this request, we will review it and get in touch within 2 working days."
          expect(page).to have_button "Send request"
        end
      end
    end
  end

  context "when user with many supported schools", js: true do
    let(:user) { create(:user, :many_supported_schools, first_name: "Generic", last_name: "User", full_name: "Generic User") }

    before do
      create(:support_organisation, urn: "100253", name: "Specialist School for Testing")
      create(:support_organisation, :with_address, urn: "100254", name: "Greendale Academy for Bright Sparks", phase: 7, number: "334", ukprn: "4346", establishment_type: create(:support_establishment_type, name: "Community school"))
    end

    context "and user is already signed in" do
      before do
        user_is_signed_in(user: user)
        visit "/procurement-support"
        find("a", text: "Start now").click
      end

      describe "user organisation page" do
        it "lists all supported schools" do
          expect(find("span.govuk-caption-l")).to have_text "About your school"
          expect(find("legend.govuk-fieldset__legend")).to have_text "Which school are you buying for?"
          expect(page).to have_unchecked_field "Specialist School for Testing"
          expect(page).to have_unchecked_field "Greendale Academy for Bright Sparks"
        end
      end

      describe "school details page" do
        before do
          choose "Greendale Academy for Bright Sparks"
          click_continue
        end

        it "shows all school details" do
          expect(find("span.govuk-caption-l")).to have_text "About your school"
          expect(find("h1.govuk-heading-l")).to have_text "Is this the school you're buying for?"
          within("dl.govuk-summary-list") do
            expect(all("dt.govuk-summary-list__key")[0]).to have_text "Name and Address"
            expect(all("dd.govuk-summary-list__value")[0]).to have_text "Greendale Academy for Bright Sparks, St James's Passage, Duke's Place, EC3A 5DE"

            expect(all("dt.govuk-summary-list__key")[1]).to have_text "Local authority"
            expect(all("dd.govuk-summary-list__value")[1]).to have_text "Camden"

            expect(all("dt.govuk-summary-list__key")[2]).to have_text "Headteacher / Principal"
            expect(all("dd.govuk-summary-list__value")[2]).to have_text "Ms Head Teacher"

            expect(all("dt.govuk-summary-list__key")[3]).to have_text "Phase of education"
            expect(all("dd.govuk-summary-list__value")[3]).to have_text "All through"

            expect(all("dt.govuk-summary-list__key")[4]).to have_text "School type"
            expect(all("dd.govuk-summary-list__value")[4]).to have_text "Community school"

            expect(all("dt.govuk-summary-list__key")[5]).to have_text "ID"
            expect(all("dd.govuk-summary-list__value")[5]).to have_text "URN: 100254 DfE number: 334 UKPRN: 4346"
          end
          expect(page).to have_unchecked_field "Yes"
          expect(page).to have_unchecked_field "No, I need to choose another school"
          expect(page).to have_button "Continue"
        end
      end

      describe "check answers page" do
        before do
          choose "Greendale Academy for Bright Sparks"
          click_continue
          choose "Yes"
          click_continue
          fill_in "framework_support_form[message_body]", with: "I have a problem"
          click_continue
        end

        it "shows the CYA page" do
          expect(find("h1.govuk-heading-l")).to have_text "Send your request"
          within("dl.govuk-summary-list") do
            expect(all("dt.govuk-summary-list__key")[0]).to have_text "Your name"
            expect(all("dd.govuk-summary-list__value")[0]).to have_text "Generic User"
            expect(all("dd.govuk-summary-list__actions")[0]).not_to have_link "Change"

            expect(all("dt.govuk-summary-list__key")[1]).to have_text "Your email address"
            expect(all("dd.govuk-summary-list__value")[1]).to have_text "test@test"
            expect(all("dd.govuk-summary-list__actions")[1]).not_to have_link "Change"

            expect(all("dt.govuk-summary-list__key")[2]).to have_text "Your school"
            expect(all("dd.govuk-summary-list__value")[2]).to have_text "Greendale Academy for Bright Sparks"
            expect(all("dd.govuk-summary-list__actions")[2]).to have_link "Change"

            expect(all("dt.govuk-summary-list__key")[3]).to have_text "Description of request"
            expect(all("dd.govuk-summary-list__value")[3]).to have_text "I have a problem"
            expect(all("dd.govuk-summary-list__actions")[3]).to have_link "Change"
          end
          expect(find("p.govuk-body")).to have_text "Once you send this request, we will review it and get in touch within 2 working days."
          expect(page).to have_button "Send request"
        end
      end
    end
  end
end
