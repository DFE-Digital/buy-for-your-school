RSpec.feature "Steps" do
  let(:user) { create(:user) }
  let(:fixture) { "task-with-multiple-steps.json" }

  before do
    user_is_signed_in(user: user)
    # TODO: setup with factory
    start_journey_from_category(category: fixture)
  end

  describe "rules" do
    context "with additional question rule" do
      let(:fixture) { "show-one-additional-question.json" }

      scenario "additional questions are shown" do
        click_first_link_in_section_list

        choose "School expert"
        click_continue

        # This question should be made visible after the previous step

        # /journeys/302e58f4-01b3-469a-906e-db6991184699
        expect(page).to have_current_path %r{/journeys/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})}
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
        click_first_link_in_section_list

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
        expect(page).to have_current_path %r{/journeys/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})/steps/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})/edit}
        expect(page).not_to have_checked_field("Lunch")
        expect(CheckboxAnswers.last.skipped).to be true
      end

      context "when the question has already been skipped" do
        scenario "selecting an answer marks the question as not being skipped" do
          click_first_link_in_section_list

          click_on("None of the above")

          within(".app-task-list") do
            expect(page).to have_content("Complete")
          end

          click_first_link_in_section_list

          check("Lunch")
          check("Dinner")
          click_on("Update")

          # /journeys/302e58f4-01b3-469a-906e-db6991184699
          expect(page).to have_current_path %r{/journeys/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})}
          expect(CheckboxAnswers.last.skipped).to be false
        end
      end
    end
  end

  describe "exceptions" do
    context "when Contentful entry model wasn't an expected type" do
      let(:fixture) { "unexpected-contentful-type.json" }

      scenario "returns an error message" do
        expect(page).to have_current_path "/journeys"
        expect(find("h1.govuk-heading-xl")).to have_text "An unexpected error occurred"
        expect(find("p.govuk-body")).to have_text "The service has had a problem trying to retrieve the required step. The team have been notified of this problem and you should be able to retry shortly."
      end
    end

    context "when the Contentful Entry wasn't an expected question type" do
      let(:fixture) { "unexpected-contentful-question-type.json" }

      scenario "returns an error message" do
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

  describe "activity logging" do
    # TODO: could this be joined with log download spec into an log_activity_spec?
    let(:fixture) { "radio-question.json" }

    context "when a new journey is begun" do
      scenario "records that action in the event log" do
        first_logged_event = ActivityLogItem.first

        # /journeys/302e58f4-01b3-469a-906e-db6991184699
        expect(page).to have_current_path %r{/journeys/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})}
        expect(first_logged_event.action).to eq("begin_journey")
        expect(first_logged_event.journey_id).to eq(Journey.last.id)
        expect(first_logged_event.user_id).to eq(User.last.id)
        expect(first_logged_event.contentful_category_id).to eq("contentful-category-entry")
      end
    end

    context "when a user views a step which has not been answered" do
      scenario "an action is recorded" do
        click_first_link_in_section_list

        step = Step.last

        last_logged_event = ActivityLogItem.last

        # /journeys/302e58f4-01b3-469a-906e-db6991184699
        expect(page).to have_current_path %r{/journeys/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})}
        expect(last_logged_event.action).to eq("begin_step")
        expect(last_logged_event.journey_id).to eq(Journey.last.id)
        expect(last_logged_event.user_id).to eq(User.last.id)
        expect(last_logged_event.contentful_category_id).to eq("contentful-category-entry")
        expect(last_logged_event.contentful_section_id).to eq(step.task.section.contentful_id)
        expect(last_logged_event.contentful_task_id).to eq(step.task.contentful_id)
        expect(last_logged_event.contentful_step_id).to eq(step.contentful_id)
      end
    end

    context "when a user views a previously answered step" do
      scenario "an action is recorded" do
        journey = Journey.last
        task = Task.find_by(title: "Radio task")
        step = task.steps.first
        create(:radio_answer, step: step)

        visit edit_journey_step_path(journey, step)

        last_logged_event = ActivityLogItem.last

        # /journeys/302e58f4-01b3-469a-906e-db6991184699/steps/46005bbe-1aa2-49bf-b0df-0f027522f50d/edit
        expect(page).to have_current_path %r{/journeys/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})/steps/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})/edit}

        expect(last_logged_event.action).to eq("view_step")
        expect(last_logged_event.journey_id).to eq(journey.id)
        expect(last_logged_event.user_id).to eq(User.last.id)
        expect(last_logged_event.contentful_category_id).to eq("contentful-category-entry")
        expect(last_logged_event.contentful_section_id).to eq(step.task.section.contentful_id)
        expect(last_logged_event.contentful_task_id).to eq(step.task.contentful_id)
        expect(last_logged_event.contentful_step_id).to eq(step.contentful_id)
      end
    end

    context "when a user answers a question" do
      let(:fixture) { "long-text-question.json" }

      scenario "an action is recorded" do
        click_first_link_in_section_list

        journey = Journey.last

        fill_in "answer[response]", with: "This is my long answer"

        click_continue

        save_answer_logged_event = ActivityLogItem.where(action: "save_answer").first

        # /journeys/302e58f4-01b3-469a-906e-db6991184699
        expect(page).to have_current_path %r{/journeys/([\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12})}
        expect(save_answer_logged_event.journey_id).to eq(journey.id)
        expect(save_answer_logged_event.user_id).to eq(User.last.id)
        expect(save_answer_logged_event.contentful_category_id).to eq("contentful-category-entry")
        expect(save_answer_logged_event.contentful_section_id).to eq(Section.last.contentful_id)
        expect(save_answer_logged_event.contentful_task_id).to eq(Task.last.contentful_id)
        expect(save_answer_logged_event.contentful_step_id).to eq(Step.last.contentful_id)
        expect(save_answer_logged_event.data["success"]).to eq true
      end
    end
  end
end
