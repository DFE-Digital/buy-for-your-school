require "rails_helper"

feature "Users can view the task list" do
  context "When a question has been answered" do
    let(:answer) { create(:short_text_answer, response: "answer") }

    scenario "The task is marked as completed" do
      visit journey_path(answer.step.journey)

      expect(page).to have_content(I18n.t("task_list.status.completed"))
    end
  end
end
