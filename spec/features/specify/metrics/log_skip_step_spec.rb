RSpec.feature "Skipping a step" do
  let(:user) { create(:user) }
  let(:step) { create(:step, :radio) }
  let(:journey) { step.journey }

  # Penultimate activity
  #
  # 1. view_journey
  # 2. begin_step
  # 3. skip_step
  # 4. view_journey
  #
  let(:logged_event) { ActivityLogItem.all[-2] }

  before do
    user_is_signed_in(user:)

    journey.update!(user:)
    visit_journey
    click_on step.task.title
    click_on "Skip for now"
  end

  it "is logged" do
    expect(logged_event.action).to eq "skip_step"
    expect(logged_event.journey_id).to eq journey.id
    expect(logged_event.user_id).to eq user.id
    expect(logged_event.contentful_category_id).to eq journey.category.contentful_id
    expect(logged_event.contentful_section_id).to eq step.task.section.contentful_id
    expect(logged_event.contentful_task_id).to eq step.task.contentful_id
    expect(logged_event.contentful_step_id).to eq step.contentful_id
  end
end
