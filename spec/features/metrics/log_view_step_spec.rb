RSpec.feature "view step" do
  let(:user) { create(:user) }
  let(:fixture) { "radio-question.json" }

  before do
    user_is_signed_in(user: user)
    # TODO: replace fixture with factory
    start_journey_from_category(category: fixture)
    click_first_link_in_section_list
  end

  context "when a user views a step which has not been answered" do
    scenario "an action is recorded" do
      step = Step.last

      last_logged_event = ActivityLogItem.last

      # /journeys/302e58f4-01b3-469a-906e-db6991184699/steps/46005bbe-1aa2-49bf-b0df-0f027522f50d
      expect(page).to have_a_step_path
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
      expect(page).to have_an_edit_step_path

      expect(last_logged_event.action).to eq("view_step")
      expect(last_logged_event.journey_id).to eq(journey.id)
      expect(last_logged_event.user_id).to eq(User.last.id)
      expect(last_logged_event.contentful_category_id).to eq("contentful-category-entry")
      expect(last_logged_event.contentful_section_id).to eq(step.task.section.contentful_id)
      expect(last_logged_event.contentful_task_id).to eq(step.task.contentful_id)
      expect(last_logged_event.contentful_step_id).to eq(step.contentful_id)
    end
  end
end
