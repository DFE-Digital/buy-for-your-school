RSpec.feature "Answering a question" do
  let(:user) { create(:user) }
  let(:answer) { create(:short_text_answer, response: "answer") }
  let(:journey) { answer.step.journey }

  # Penultimate activity
  #
  # 1. view_journey
  # 2. view_step
  # 3. update_answer
  # 4. view_journey
  #
  let(:logged_event) { ActivityLogItem.all[-2] }

  before do
    user_is_signed_in(user:)

    journey.update!(user:)
    visit_journey
    click_on answer.step.task.title
    fill_in "answer[response]", with: "email@example.com"
    click_update
  end

  it "is logged" do
    expect(logged_event.action).to eq "update_answer"
    expect(logged_event.journey_id).to eq journey.id
    expect(logged_event.user_id).to eq user.id
    expect(logged_event.contentful_category_id).to eq journey.category.contentful_id
    expect(logged_event.contentful_section_id).to eq answer.step.task.section.contentful_id
    expect(logged_event.contentful_task_id).to eq answer.step.task.contentful_id
    expect(logged_event.contentful_step_id).to eq answer.step.contentful_id
    expect(logged_event.data["success"]).to be true
  end
end
