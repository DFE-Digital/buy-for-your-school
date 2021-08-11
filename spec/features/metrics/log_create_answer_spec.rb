RSpec.feature "create answer" do
  let(:user) { create(:user) }
  let(:fixture) { "long-text-question.json" }

  before do
    user_is_signed_in(user: user)
    # TODO: replace fixture with factory
    start_journey_from_category(category: fixture)
    click_first_link_in_section_list
  end

  context "when a user answers a question" do
    scenario "an action is recorded" do
      journey = Journey.last

      fill_in "answer[response]", with: "This is my long answer"

      click_continue

      save_answer_logged_event = ActivityLogItem.where(action: "save_answer").first

      # /journeys/302e58f4-01b3-469a-906e-db6991184699
      expect(page).to have_a_journey_path
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
