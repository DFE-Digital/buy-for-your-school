RSpec.feature "Viewing a specification" do
  let(:user) { create(:user) }
  let(:journey) { create(:journey, user:) }
  let(:logged_event) { ActivityLogItem.last }

  before do
    user_is_signed_in(user:)
    visit_journey
    click_view
  end

  describe "is logged" do
    scenario "requesting the HTML version" do
      expect(logged_event.action).to eq "view_specification"
      expect(logged_event.journey_id).to eq journey.id
      expect(logged_event.user_id).to eq user.id
      expect(logged_event.contentful_category_id).to eq journey.category.contentful_id
      expect(logged_event.data["format"]).to eq "html"
    end
  end
end
