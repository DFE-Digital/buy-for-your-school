RSpec.feature "Users can see their catering specification" do
  let(:user) { create(:user) }
  let(:journey) { Journey.last }
  let(:last_logged_event) { ActivityLogItem.last }

  before do
    user_is_signed_in(user: user)
    start_journey_from_category(category: "category-with-liquid-template.json")
    click_view
  end

  context "when viewing a journey" do
    scenario "requesting the HTML version records an action" do
      expect(last_logged_event.action).to eq "view_specification"
      expect(last_logged_event.journey_id).to eq journey.id
      expect(last_logged_event.user_id).to eq user.id
      expect(last_logged_event.contentful_category_id).to eq "contentful-category-entry"
      expect(last_logged_event.data["format"]).to eq "html"
    end

    scenario "requesting the .docx version records an action" do
      click_on "Download (.docx)"

      expect(last_logged_event.action).to eq "view_specification"
      expect(last_logged_event.journey_id).to eq journey.id
      expect(last_logged_event.user_id).to eq user.id
      expect(last_logged_event.contentful_category_id).to eq "contentful-category-entry"
      expect(last_logged_event.data["format"]).to eq "docx"
    end
  end
end
