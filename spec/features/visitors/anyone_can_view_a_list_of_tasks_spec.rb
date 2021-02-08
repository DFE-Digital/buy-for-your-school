require "rails_helper"

feature "Users can view the task list" do
  it "tasks are grouped by their section" do
    stub_contentful_category(fixture_filename: "multiple-sections.json")

    visit root_path

    click_on(I18n.t("generic.button.start"))

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

  context "When a question has been answered" do
    before do
      journey = answer.step.journey
      journey.update(section_groups: [
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
    end
    let(:answer) { create(:short_text_answer, response: "answer") }

    scenario "The task is marked as completed" do
      visit journey_path(answer.step.journey)

      expect(page).to have_content(I18n.t("task_list.status.completed"))
    end
  end
end
