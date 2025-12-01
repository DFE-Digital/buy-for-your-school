RSpec.feature "Viewing a journey" do
  let(:user) { create(:user) }
  let(:journey) { create(:journey, user:) }
  let(:logged_event) { ActivityLogItem.last }

  before do
    user_is_signed_in(user:)
    visit_journey
  end

  it "is logged" do
    expect(logged_event.action).to eq "view_journey"
    expect(logged_event.journey_id).to eq journey.id
    expect(logged_event.user_id).to eq user.id
    expect(logged_event.contentful_category_id).to eq journey.category.contentful_id
  end
end
