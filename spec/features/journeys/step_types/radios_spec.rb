RSpec.feature "radios" do
  let(:user) { create(:user) }
  let(:fixture) { "extended-radio-question.json" }

  before do
    user_is_signed_in(user: user)
    # TODO: setup with factory
    start_journey_from_category(category: fixture)
    click_first_link_in_section_list
  end

  context "when the step is of type radios" do
    context "when extra configuration is passed to collect further info" do
      scenario "asks the user for further information" do
        choose "Catering"
        expect(page).not_to have_content("No_further_information") # It should not create a label when one isn't specified
        within("span.govuk-visually-hidden") do
          expect(page).to have_content("Optional further information") # Default the hidden label to something understandable for screen readers
        end

        fill_in "answer[catering_further_information]", with: "The school needs the kitchen cleaned once a day"

        click_continue

        click_first_link_in_section_list

        # /journeys/302e58f4-01b3-469a-906e-db6991184699/steps/46005bbe-1aa2-49bf-b0df-0f027522f50d/edit
        expect(page).to have_an_edit_step_path
        expect(page).to have_checked_field("Catering")
        expect(find_field("answer-catering-further-information-field").value)
          .to eql("The school needs the kitchen cleaned once a day")
      end
    end

    context "when extended question is of type single" do
      scenario "a single text field is displayed" do
        choose "Catering"

        # /journeys/302e58f4-01b3-469a-906e-db6991184699/steps/46005bbe-1aa2-49bf-b0df-0f027522f50d
        expect(page).to have_a_step_path
        expect(page).to have_selector("input#answer-catering-further-information-field")
      end
    end

    context "when extended question is of type long" do
      let(:fixture) { "extended-long-answer-radio-question.json" }

      scenario "a long text area is displayed" do
        choose "Catering"

        # /journeys/302e58f4-01b3-469a-906e-db6991184699/steps/46005bbe-1aa2-49bf-b0df-0f027522f50d
        expect(page).to have_a_step_path
        expect(page).to have_selector("textarea#answer-catering-further-information-field")
      end
    end

    context "when there is no extended question" do
      let(:fixture) { "radio-question.json" }

      scenario "no extra text field is displayed" do
        # /journeys/302e58f4-01b3-469a-906e-db6991184699/steps/46005bbe-1aa2-49bf-b0df-0f027522f50d
        expect(page).to have_a_step_path
        expect(page).not_to have_selector("textarea#answer-catering-further-information-field")
        expect(page).not_to have_selector("input#answer-catering-further-information-field")
      end
    end

    context "when an 'or separator' has been configured" do
      let(:fixture) { "radio-question-with-separator.json" }

      scenario "shows an or separator" do
        expect(page).to have_selector("div.govuk-radios__divider")
        within("div.govuk-radios__divider") do
          expect(page).to have_content("or")
        end

        # /journeys/302e58f4-01b3-469a-906e-db6991184699/steps/46005bbe-1aa2-49bf-b0df-0f027522f50d
        expect(page).to have_a_step_path
        # Check that the "Or" separator appears in the correct position
        expect(page.body.index("Catering") > page.body.index("or")).to eq(true)
        expect(page.body.index("or") < page.body.index("Cleaning")).to eq(true)
      end
    end
  end
end
