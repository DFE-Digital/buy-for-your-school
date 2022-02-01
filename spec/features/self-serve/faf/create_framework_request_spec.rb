RSpec.describe "Create a new framework request" do
  context "when user with one supported school" do
    let(:user) { create(:user, :one_supported_school, first_name: "Generic", last_name: "User", full_name: "Generic User") }

    before do
      stub_request(:post, "https://api.notifications.service.gov.uk/v2/notifications/email")
      .to_return(body: {}.to_json, status: 200, headers: {})
    end

    context "when user is already signed in" do
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

      xit "navigates to check answers page from how we can help" do
        find("a", text: "Start now").click
        fill_in "framework_support_form[message_body]", with: "I have a problem"
        click_continue
        expect(all("dd.govuk-summary-list__value")[3]).to have_text "I have a problem"
        expect(FrameworkRequest.count).to eq(1)
        expect(find("h1.govuk-heading-l")).to have_text "Send your request"
      end

      xit "navigates to confirmation page upon sending request" do
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
          expect(page).to have_link("about frameworks", href: url)
        end

        it "navigates to the planning for what you're buying page in an external tab" do
          url = "https://www.gov.uk/guidance/buying-for-schools"
          expect(page).to have_link("planning for what you're buying", href: url)
        end

        it "navigates to the finding the right way to buy page in an external tab" do
          url = "https://www.gov.uk/guidance/buying-procedures-and-procurement-law-for-schools"
          expect(page).to have_link("finding the right way to buy", href: url)
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
          expect(find("legend")).to have_text "Do you have a DfE Sign-in account linked to the school that your request is about?"
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

      describe "contact info page" do
        before do
          visit "/procurement-support/new"
          choose "Yes, use my DfE Sign-in"
          click_continue
          user_exists_in_dfe_sign_in(user: user)
          click_on "Sign in"
        end

        xit "loads the page" do
          pp page.source
          expect(find("span.govuk-caption-l")).to have_text "About you"
          expect(find("h1.govuk-heading-l")).to have_text "Is this your contact information?"
          expect(all("p")[1]).to have_text "If these details are not correct, you can either:"

          within("ul.govuk-list") do
            expect(all("li")[0]).to have_text "log in with the correct account, or"
            expect(all("li")[1]).to have_link "amend your DfE Sign-in account details", href: "https://test-profile.signin.education.gov.uk/edit-details", class: "govuk-link"
          end

          within("dl.govuk-summary-list") do
            expect(all("dt")[0]).to have_text "Name"
            expect(all("dd")[0]).to have_text "first_name last_name"
            expect(all("dt")[1]).to have_text "Email address"
            expect(all("dd")[1]).to have_text "test@test"
          end

          expect(page).to have_button "Yes, continue"
        end
      end

      describe "user organisation page" do
        before do
          visit "/procurement-support/new"
          choose "Yes, use my DfE Sign-in"
          click_continue
          user_exists_in_dfe_sign_in(user: user)
          click_on "Sign in"
        end

        xit "skips step 3 because the school is implicit" do
          expect(page).not_to have_unchecked_field "Specialist School for Testing"
          expect(find("span.govuk-caption-l")).to have_text "About your request"
        end
      end

      xdescribe "user query page" do
        before do
          visit "/procurement-support/new"
          find("label", text: "Yes, use my DfE Sign-in").click
          user_exists_in_dfe_sign_in(user: user)
          click_on "Sign in"
          click_continue
          click_continue
          click_continue
        end

        it "has a back link to step 3" do
          click_on "Back"
          expect(page).to have_current_path "/procurement-support?faf_form%5Bback%5D=true&faf_form%5Bdsi%5D=true&faf_form%5Bmessage_body%5D=&faf_form%5Bschool_urn%5D=urn-type-1&faf_form%5Bstep%5D=4"
        end

        it "raises a validation error if no message entered" do
          click_continue

          expect(find("h2.govuk-error-summary__title")).to have_text "There is a problem"
          expect(page).to have_link "You must tell us how we can help", href: "#faf-form-message-body-field-error"
          expect(find(".govuk-error-message")).to have_text "You must tell us how we can help"
        end

        it "submits a support request message" do
          fill_in "framework_support_form[message_body]", with: "I have a problem"
          click_continue

          expect(FrameworkRequest.count).to eq(1)
        end
      end

      xdescribe "check answers page" do
        before do
          create(:support_organisation, urn: "urn-type-1", name: "School #1")

          user_is_signed_in(user: user)
          # start DSI journey
          visit "/procurement-support/new"
          # step 1
          choose "Yes, use my DfE Sign-in"
          click_continue
          # step 2
          click_on "Yes, continue"
          # step 4
          fill_in "faf_form[message_body]", with: "I have a problem"
          click_continue
        end

        it "shows the CYA page" do
          expect(find("h1.govuk-heading-l")).to have_text "Send your request"
          within("dl.govuk-summary-list") do
            expect(all("dt.govuk-summary-list__key")[0]).to have_text "Your name"
            expect(all("dd.govuk-summary-list__value")[0]).to have_text "first_name last_name"
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

  # xcontext "when user with many supported schools" do
  #   xcontext "and user is already signed in" do
  #   end

  #   xcontext "and is not already signed in" do
  #   end
  # end
end
