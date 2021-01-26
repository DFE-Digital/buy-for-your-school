require "rails_helper"

feature "Users can view the task list" do
  context "When a question has not been answered" do
    let(:step) { create(:step, :short_text) }

    scenario "The task is marked as not started" do
      visit journey_path(step.journey)

      expect(page).to have_content(I18n.t("task_list.status.not_started"))
    end
  end

  context "When a question has been answered" do
    let(:answer) { create(:short_text_answer, response: "answer") }

    scenario "The task is marked as completed" do
      visit journey_path(answer.step.journey)

      expect(page).to have_content(I18n.t("task_list.status.completed"))
    end
  end
end
