require "rails_helper"

feature "Users can view the task list" do
  let(:user) { create(:user) }
  before { user_is_signed_in(user: user) }

  it "tasks are grouped by their section" do
    start_journey_from_category(category: "multiple-sections.json")

    within(".app-task-list") do
      expect(page).to have_content("Section A")
      expect(page).to have_content("Section B")
    end

    task_lists = find_all(".app-task-list__items")

    within(task_lists[0]) do
      expect(page).to have_content("Which service do you need?")
    end

    within(task_lists[1]) do
      expect(page).to have_content("Describe what you need")
    end
  end

  scenario "user can navigate back to the dashboard" do
    start_journey_from_category(category: "extended-radio-question.json")

    click_on(I18n.t("generic.button.back"))

    expect(page).to have_content(I18n.t("dashboard.header"))
  end

  context "When a question has been answered" do
    scenario "The task is marked as completed" do
      stub_contentful_category(fixture_filename: "multiple-sections.json")

      answer = create(:short_text_answer, response: "answer")
      answer.step.journey.update(
        user: user,
        section_groups: [
          {
            "order" => 0,
            "title" => "Section A",
            "steps" => [
              {
                "contentful_id" => answer.step.contentful_id,
                "order" => 0
              }
            ]
          }
        ]
      )

      user_starts_the_journey

      visit journey_path(answer.step.journey)

      expect(page).to have_content(I18n.t("task_list.status.completed"))
    end
  end

  context "When a question has been hidden" do
    it "should not appear in the task list" do
      start_journey_from_category(category: "hidden-field.json")

      expect(page).not_to have_content("You should NOT be able to see this question")
      expect(page).to have_content("You should be able to see this question")
    end
  end

  context "When the sections & tasks are retrieved from the database (new task list process)" do
    context "When there is a task with a single step" do
      it "shows the section title" do
        start_journey_with_tasks_from_category(category: "section-with-single-task.json")
        within(".app-task-list") do
          expect(page).to have_content("Section with a single task")
        end
      end

      it "shows the step title, not the task title" do
        start_journey_with_tasks_from_category(category: "section-with-single-task.json")

        within(".app-task-list") do
          expect(page).to have_content("Everyday services that are required and need to be considered")
          expect(page).to_not have_content("Task with a single step")
        end
      end

      it "has a back link on the step page that takes you to the journey page" do
        start_journey_with_tasks_from_category(category: "section-with-single-task.json")

        within(".app-task-list") do
          click_on "Everyday services that are required and need to be considered"
        end

        click_on "Back"

        expect(page).to have_content "Section with a single task"
      end

      it "allows the user to complete the step, and returns to the journey page" do
        start_journey_with_tasks_from_category(category: "section-with-single-task.json")

        within(".app-task-list") do
          click_on "Everyday services that are required and need to be considered"
        end

        check "Lunch"
        click_on "Continue"

        expect(page).to have_content "Section with a single task"
        within(".app-task-list") do
          expect(page).to have_content("Complete")
        end
      end
    end

    context "When there is a task with a single HIDDEN step" do
      it "shows the section title" do
        start_journey_with_tasks_from_category(category: "section-with-single-hidden-task.json")
        within(".app-task-list") do
          expect(page).to have_content("Section with a hidden task")
        end
      end

      it "does not show the task nor step title" do
        start_journey_with_tasks_from_category(category: "section-with-single-hidden-task.json")

        within(".app-task-list") do
          expect(page).to_not have_content("Task with a hidden step")
        end
      end
    end

    context "When there is a task with multiple steps" do
      it "shows the section title" do
        start_journey_with_tasks_from_category(category: "section-with-multiple-tasks.json")
        within(".app-task-list") do
          expect(page).to have_content("Section with multiple tasks")
        end
      end

      it "shows the task titles within the section" do
        start_journey_with_tasks_from_category(category: "section-with-multiple-tasks.json")

        within(".app-task-list") do
          expect(page).to have_content("Task with multiple steps")
        end
      end
    end
  end
end
