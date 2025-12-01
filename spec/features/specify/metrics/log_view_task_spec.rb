RSpec.feature "User task actions are recorded" do
  let(:user) { create(:user) }
  let(:category) { create(:category, :catering, contentful_id: "contentful-category-entry") }
  let(:journey) { create(:journey, user:, category:) }
  let(:section) { create(:section, title: "Catering", journey:, contentful_id: "contentful-section-entry") }

  before do
    user_is_signed_in(user:)
  end

  context "when there is a task with multiple steps" do
    before do
      task_checkbox_and_radio = create(:task, title: "Task with multiple steps", section:)
      create(:step, :radio, title: "Which service do you need?", options: [{ "value" => "Catering" }], task: task_checkbox_and_radio, order: 0)
      create(:step, :short_text, title: "What email address did you use?", task: task_checkbox_and_radio, order: 1)
      create(:step, :long_text, title: "Describe what you need", task: task_checkbox_and_radio, order: 2)
      create(:step, :checkbox, title: "Everyday services that are required and need to be considered", options: [{ "value" => "Breakfast" }], task: task_checkbox_and_radio, order: 3)
      visit "/journeys/#{journey.id}"
    end

    it "records an action in the event log that a task has begun" do
      # /journeys/b68300eb-fbeb-4ac5-beb8-4f88eb1f86cd
      expect(page).to have_a_journey_path

      within(".app-task-list") do
        click_on "Task with multiple steps"
      end

      # /journeys/40e87654-0ce7-466a-96a2-b406025c83d9/steps/36e7b670-1af5-4340-9311-fc23ae1a6cfd
      expect(page).to have_a_step_path

      journey = Journey.first
      task = Task.find_by(title: "Task with multiple steps")

      # The process of starting a task also records entering the first step. We
      # explicitly select the event with the "begin_task" action and check it
      # matches our expectations.
      begin_task_logged_event = ActivityLogItem.where(action: "begin_task").first
      expect(begin_task_logged_event.journey_id).to eq(journey.id)
      expect(begin_task_logged_event.user_id).to eq(user.id)
      expect(begin_task_logged_event.contentful_category_id).to eq "contentful-category-entry"
      expect(begin_task_logged_event.contentful_section_id).to eq "contentful-section-entry"
      expect(begin_task_logged_event.contentful_task_id).to eq(task.contentful_id)
      expect(begin_task_logged_event.data["task_status"]).to eq 0 # Task::NOT_STARTED
      expect(begin_task_logged_event.data["task_step_tally"]).to eq({
        "total" => 4,
        "hidden" => 0,
        "visible" => 4,
        "answered" => 0,
        "completed" => 0,
        "questions" => 4,
        "skipped" => 0,
        "statements" => 0,
        "acknowledged" => 0,
      })
    end

    context "when a task has at least one answered step" do
      it "records an action in the event log that an in-progress task has been revisited" do
        task = Task.find_by(title: "Task with multiple steps")
        step = task.steps.first
        create(:radio_answer, step:)

        # /journeys/3303d91e-e09a-4956-90d5-2628564ae901
        expect(page).to have_a_journey_path

        within(".app-task-list") do
          click_on "Task with multiple steps"
        end

        # /journeys/3303d91e-e09a-4956-90d5-2628564ae901/tasks/4f8e2f76-cad2-4b43-be6d-18eca22a9756
        expect(page).to have_a_task_path

        journey = Journey.first

        last_logged_event = ActivityLogItem.last
        expect(last_logged_event.action).to eq "view_task"
        expect(last_logged_event.journey_id).to eq(journey.id)
        expect(last_logged_event.user_id).to eq(user.id)
        expect(last_logged_event.contentful_category_id).to eq "contentful-category-entry"
        expect(last_logged_event.contentful_section_id).to eq "contentful-section-entry"
        expect(last_logged_event.contentful_task_id).to eq(task.contentful_id)
        expect(last_logged_event.data["task_status"]).to eq 1 # Task::IN_PROGRESS
        expect(last_logged_event.data["task_step_tally"]).to eq({
          "total" => 4,
          "hidden" => 0,
          "visible" => 4,
          "answered" => 1,
          "completed" => 1,
          "questions" => 4,
          "skipped" => 0,
          "statements" => 0,
          "acknowledged" => 0,
        })
      end
    end

    context "when all questions in a task have been answered" do
      it "records an action in the event log that a completed task has been revisited" do
        # /journeys/db0d0480-4598-4ddb-b003-571138f5cf98
        expect(page).to have_a_journey_path
        within(".app-task-list") do
          click_on "Task with multiple steps"
        end

        # /journeys/db0d0480-4598-4ddb-b003-571138f5cf98/steps/e25ab926-cec4-4c42-b6bf-2821ece220d4
        expect(page).to have_a_step_path

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
        expect(last_logged_event.contentful_section_id).to eq "contentful-section-entry"
        expect(last_logged_event.contentful_task_id).to eq(task.contentful_id)
        expect(last_logged_event.data["task_status"]).to eq 2 # Task::COMPLETED
        expect(last_logged_event.data["task_step_tally"]).to eq({
          "total" => 4,
          "hidden" => 0,
          "visible" => 4,
          "answered" => 4,
          "completed" => 4,
          "questions" => 4,
          "skipped" => 0,
          "statements" => 0,
          "acknowledged" => 0,
        })
      end
    end
  end
end
