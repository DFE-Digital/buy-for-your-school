RSpec.feature "Users can view an ordered list of sections" do
  let(:user) { create(:user) }
  let(:category) { create(:category) }
  let(:journey) { create(:journey, user:, category:) }

  before do
    user_is_signed_in(user:)
  end

  it "the user can see multiple sections" do
    create(:section, journey:, title: "Section A", order: 0)
    create(:section, journey:, title: "Section B", order: 1)
    create(:section, journey:, title: "Section C", order: 2)

    visit "/journeys/#{journey.id}"

    within(".app-task-list") do
      section_headings = find_all("h2.app-task-list__section")
      expect(section_headings[0]).to have_text "Section A"
      expect(section_headings[1]).to have_text "Section B"
      expect(section_headings[2]).to have_text "Section C"
    end
  end

  context "when sections are saved in a different order than in Contentful" do
    before do
      # Create sections with different created_at to simulate slow database inserts/selects
      create(:section, journey:, title: "Section A", order: 0, created_at: 2.hours.ago)
      create(:section, journey:, title: "Section B", order: 1, created_at: 1.hour.ago)
      create(:section, journey:, title: "Section C", order: 2, created_at: 3.hours.ago)

      visit "/journeys/#{journey.id}"
    end

    it "the user continues to be shown the order defined by Contentful" do
      within(".app-task-list") do
        section_headings = find_all("h2.app-task-list__section")
        expect(section_headings[0]).to have_text "Section A"
        expect(section_headings[1]).to have_text "Section B"
        expect(section_headings[2]).to have_text "Section C"
      end
    end
  end
end
