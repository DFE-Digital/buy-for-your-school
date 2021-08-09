RSpec.feature "User task actions are recorded" do
  let(:user) { create(:user) }
  let(:fixture) { "section-with-multiple-tasks.json" }

  before do
    user_is_signed_in(user: user)
    # TODO: replace fixture with factory
    start_journey_from_category(category: fixture)
  end

  context "when there is a task with multiple steps" do
    it "records an action in the event log that a task has begun" do
      expect(page).to have_current_path %r{/journeys/.*}

      within(".app-task-list") do
        click_on "Task with multiple steps" # > checkboxes-and-radio-task.json
      end

      expect(page).to have_current_path %r{/journeys/.*/steps/.*}

      journey = Journey.first
      task = Task.find_by(title: "Task with multiple steps")

      # The process of starting a task also records entering the first step. We
      # explicitly select the event with the "begin_task" action and check it
      # matches our expectations.
      begin_task_logged_event = ActivityLogItem.where(action: "begin_task").first
      expect(begin_task_logged_event.journey_id).to eq(journey.id)
      expect(begin_task_logged_event.user_id).to eq(user.id)
      expect(begin_task_logged_event.contentful_category_id).to eq "contentful-category-entry"
      expect(begin_task_logged_event.contentful_section_id).to eq "multiple-tasks-section"
      expect(begin_task_logged_event.contentful_task_id).to eq(task.contentful_id)
      expect(begin_task_logged_event.data["task_status"]).to eq 0 # Task::NOT_STARTED
      expect(begin_task_logged_event.data["task_step_tally"]).to eq({
        "total" => 4,
        "hidden" => 0,
        "visible" => 4,
        "answered" => 0,
        "completed" => 0,
        "questions" => 4,
        "statements" => 0,
        "acknowledged" => 0,
      })
    end

    context "when a task has at least one answered step" do
      it "records an action in the event log that an in-progress task has been revisited" do
        task = Task.find_by(title: "Task with multiple steps")
        step = task.steps.first
        create(:radio_answer, step: step)

        expect(page).to have_current_path %r{/journeys/.*}

        within(".app-task-list") do
          click_on "Task with multiple steps" # > checkboxes-and-radio-task.json
        end

        expect(page).to have_current_path %r{/journeys/.*/tasks/.*}

        journey = Journey.first

        last_logged_event = ActivityLogItem.last
        expect(last_logged_event.action).to eq "view_task"
        expect(last_logged_event.journey_id).to eq(journey.id)
        expect(last_logged_event.user_id).to eq(user.id)
        expect(last_logged_event.contentful_category_id).to eq "contentful-category-entry"
        expect(last_logged_event.contentful_section_id).to eq "multiple-tasks-section"
        expect(last_logged_event.contentful_task_id).to eq(task.contentful_id)
        expect(last_logged_event.data["task_status"]).to eq 1 # Task::IN_PROGRESS
        expect(last_logged_event.data["task_step_tally"]).to eq({
          "total" => 4,
          "hidden" => 0,
          "visible" => 4,
          "answered" => 1,
          "completed" => 1,
          "questions" => 4,
          "statements" => 0,
          "acknowledged" => 0,
        })
      end
    end

    context "when all questions in a task have been answered" do
      it "records an action in the event log that a completed task has been revisited" do
        expect(page).to have_current_path %r{/journeys/.*}
        within(".app-task-list") do
          click_on "Task with multiple steps" # > checkboxes-and-radio-task.json
        end

        expect(page).to have_current_path %r{/journeys/.*/steps/.*}

        choose "Catering"
        click_continue

        fill_in "answer[response]", with: "This is my short answer"
        click_continue

        fill_in "answer[response]", with: "This is my long answer"
        click_continue

        check "Breakfast"
        click_continue

        task = Task.find_by(title: "Task with multiple steps")
        journey = Journey.first

        last_logged_event = ActivityLogItem.last
        expect(last_logged_event.action).to eq "view_task"
        expect(last_logged_event.journey_id).to eq(journey.id)
        expect(last_logged_event.user_id).to eq(user.id)
        expect(last_logged_event.contentful_category_id).to eq "contentful-category-entry"
        expect(last_logged_event.contentful_section_id).to eq "multiple-tasks-section"
        expect(last_logged_event.contentful_task_id).to eq(task.contentful_id)
        expect(last_logged_event.data["task_status"]).to eq 2 # Task::COMPLETED
        expect(last_logged_event.data["task_step_tally"]).to eq({
          "total" => 4,
          "hidden" => 0,
          "visible" => 4,
          "answered" => 4,
          "completed" => 4,
          "questions" => 4,
          "statements" => 0,
          "acknowledged" => 0,
        })
      end
    end
  end
end
