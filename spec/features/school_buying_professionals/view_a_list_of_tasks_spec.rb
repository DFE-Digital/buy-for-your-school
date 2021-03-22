require "rails_helper"

feature "Users can view the task list" do
  before { user_is_signed_in }

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
      answer.step.journey.update(section_groups: [
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
      ])

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
end
