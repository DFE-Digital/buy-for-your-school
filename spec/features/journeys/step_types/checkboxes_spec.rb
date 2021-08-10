RSpec.feature "checkboxes" do
  let(:user) { create(:user) }
  let(:fixture) { "checkboxes-question.json" }

  before do
    user_is_signed_in(user: user)
    # TODO: setup with factory
    start_journey_from_category(category: fixture)
  end

  context "when the step is of type checkboxes" do
    scenario "user can select multiple answers" do
      click_first_link_in_section_list

      check "Breakfast"
      check "Lunch"

      click_continue

      click_first_link_in_section_list

      # /journeys/302e58f4-01b3-469a-906e-db6991184699/steps/46005bbe-1aa2-49bf-b0df-0f027522f50d/edit
      expect(page).to have_current_path %r{/journeys/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})/steps/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})/edit}
      expect(page).to have_checked_field("answer-response-breakfast-field")
      expect(page).to have_checked_field("answer-response-lunch-field")
    end

    scenario "options follow the capitalisation given" do
      click_first_link_in_section_list

      # /journeys/302e58f4-01b3-469a-906e-db6991184699/steps/46005bbe-1aa2-49bf-b0df-0f027522f50d
      expect(page).to have_current_path %r{/journeys/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})/steps/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})}
      expect(find("div.govuk-checkboxes")).to have_text "Morning break"
    end

    context "with extended checkboxes" do
      let(:fixture) { "extended-checkboxes-question.json" }

      context "when extra configuration is passed to collect further info" do
        scenario "asks the user for further information" do
          click_first_link_in_section_list

          check "Yes"
          fill_in "answer[yes_further_information]", with: "The first piece of further information"

          check "No"
          expect(page).not_to have_content("No_further_information") # It should not create a label when text for one isn't provided
          within("span.govuk-visually-hidden") do
            expect(page).to have_content("Optional further information") # Default the hidden label to something understandable for screen readers
          end
          fill_in "answer[no_further_information]", with: "A second piece of further information"

          # We are testing a value that includes a comma
          check "Other, please specify"
          fill_in "answer[other_please_specify_further_information]", with: "Other information"

          click_continue

          click_first_link_in_section_list

          # /journeys/302e58f4-01b3-469a-906e-db6991184699/steps/46005bbe-1aa2-49bf-b0df-0f027522f50d/edit
          expect(page).to have_current_path %r{/journeys/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})/steps/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})/edit}

          expect(page).to have_checked_field("Yes")
          expect(find_field("answer-yes-further-information-field").value)
            .to eql("The first piece of further information")

          expect(page).to have_checked_field("No")
          expect(find_field("answer-no-further-information-field").value)
            .to eql("A second piece of further information")

          expect(page).to have_checked_field("Other, please specify")
          expect(find_field("answer-other-please-specify-further-information-field").value)
            .to eql("Other information")
        end
      end

      context "when extended question is of type single" do
        scenario "a single text field is displayed" do
          click_first_link_in_section_list
          check "Yes"

          # /journeys/302e58f4-01b3-469a-906e-db6991184699/steps/46005bbe-1aa2-49bf-b0df-0f027522f50d
          expect(page).to have_current_path %r{/journeys/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})/steps/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})}
          expect(page).to have_selector("input#answer-yes-further-information-field")
        end
      end
    end

    context "when extended question is of type long" do
      # TODO: setup with factory
      let(:fixture) { "extended-long-answer-checkboxes-question.json" }

      scenario "a long text area is displayed" do
        click_first_link_in_section_list
        check "Yes"

        # /journeys/302e58f4-01b3-469a-906e-db6991184699/steps/46005bbe-1aa2-49bf-b0df-0f027522f50d
        expect(page).to have_current_path %r{/journeys/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})/steps/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})}
        expect(page).to have_selector("textarea#answer-yes-further-information-field")
      end
    end

    context "when there is no extended question" do
      scenario "no extra text field is displayed" do
        click_first_link_in_section_list

        # /journeys/302e58f4-01b3-469a-906e-db6991184699/steps/46005bbe-1aa2-49bf-b0df-0f027522f50d
        expect(page).to have_current_path %r{/journeys/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})/steps/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})}
        expect(page).not_to have_selector("textarea#answer-yes-further-information-field")
        expect(page).not_to have_selector("input#answer-yes-further-information-field")
      end
    end
  end
end
