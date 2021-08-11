RSpec.feature "Steps" do
  let(:user) { create(:user) }
  let(:fixture) { "task-with-multiple-steps.json" }

  before do |example|
    user_is_signed_in(user: user)
    # TODO: setup with factory
    start_journey_from_category(category: fixture)
    unless example.metadata[:skip_click_first_link_in_section]
      click_first_link_in_section_list
    end
  end

  describe "rules" do
    context "with additional question rule" do
      let(:fixture) { "show-one-additional-question.json" }

      scenario "additional questions are shown" do
        choose "School expert"
        click_continue

        # This question should be made visible after the previous step

        # /journeys/302e58f4-01b3-469a-906e-db6991184699
        expect(page).to have_a_journey_path
        expect(page).not_to have_content("What colour is the sky?")
        click_on("Hidden field with additional question task")
        choose("Red")
        click_continue

        # This question should only be made visible after the previous step
        click_on("Hidden field task")
        choose("School expert")
        click_continue
      end
    end

    context "with skippable rule" do
      let(:fixture) { "skippable-checkboxes-question.json" }

      scenario "allows the user to not select an answer" do
        click_continue
        expect(find("span.govuk-error-message")).to have_text "can't be blank"

        check("Lunch")
        check("Dinner")
        click_continue

        click_first_link_in_section_list

        click_on("None of the above")

        within(".app-task-list") do
          expect(page).to have_content("Complete")
        end

        click_first_link_in_section_list

        # /journeys/302e58f4-01b3-469a-906e-db6991184699/steps/46005bbe-1aa2-49bf-b0df-0f027522f50d/edit
        expect(page).to have_an_edit_step_path
        expect(page).not_to have_checked_field("Lunch")
        expect(CheckboxAnswers.last.skipped).to be true
      end

      context "when the question has already been skipped" do
        scenario "selecting an answer marks the question as not being skipped" do
          click_on("None of the above")

          within(".app-task-list") do
            expect(page).to have_content("Complete")
          end

          click_first_link_in_section_list

          check("Lunch")
          check("Dinner")
          click_on("Update")

          # /journeys/302e58f4-01b3-469a-906e-db6991184699
          expect(page).to have_a_journey_path
          expect(CheckboxAnswers.last.skipped).to be false
        end
      end
    end
  end

  describe "exceptions" do
    context "when Contentful entry model wasn't an expected type", skip_click_first_link_in_section: true do
      let(:fixture) { "unexpected-contentful-type.json" }

      scenario "returns an error message" do
        expect(page).to have_current_path "/journeys"
        expect(find("h1.govuk-heading-xl")).to have_text "An unexpected error occurred"
        expect(find("p.govuk-body")).to have_text "The service has had a problem trying to retrieve the required step. The team have been notified of this problem and you should be able to retry shortly."
      end
    end

    context "when the Contentful Entry wasn't an expected question type" do
      let(:fixture) { "unexpected-contentful-question-type.json" }

      scenario "returns an error message", skip_click_first_link_in_section: true do
        expect(page).to have_current_path "/journeys"
        expect(find("h1.govuk-heading-xl")).to have_text "An unexpected error occurred"
        expect(find("p.govuk-body")).to have_text "The service has had a problem trying to retrieve the required step. The team have been notified of this problem and you should be able to retry shortly."
      end
    end

    context "when the starting entry id doesn't exist" do
      scenario "a Contentful entry_id does not exist" do
        allow(stub_client).to receive(:by_id).with("contentful-category-entry").and_return(nil)

        category = create(:category, contentful_id: "contentful-category-entry")

        user_signs_in_and_starts_the_journey(category.id)

        expect(page).to have_current_path "/journeys"
        expect(find("h1.govuk-heading-xl")).to have_text "An unexpected error occurred"
        expect(find("p.govuk-body")).to have_text "The service has had a problem trying to retrieve the required step. The team have been notified of this problem and you should be able to retry shortly."
      end
    end
  end
end
