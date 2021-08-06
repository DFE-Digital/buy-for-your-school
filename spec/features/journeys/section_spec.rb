RSpec.feature "Users can view a list of sections" do
  let(:user) { create(:user) }
  let(:category) { create(:category) }
  let(:journey) { create(:journey, user: user, category: category) }

  before do
    create(:section, journey: journey, title: "Section A")
    create(:section, journey: journey, title: "Section B")

    user_is_signed_in(user: user)
    visit "/journeys/#{journey.id}"
  end

  it "the user can see multiple sections" do
    within(".app-task-list") do
      expect(page).to have_content "Section A"
      expect(page).to have_content "Section B"
    end
  end

  context "when sections are saved in a different order than in Contentful" do
    it "the user continues to be shown the order defined by Contentful" do
      # Manually modify the created_at to simlate slow database inserts/selects
      first_section = Section.find_by(title: "Section A")
      first_section.update!(created_at: Time.zone.now - 2.hours)
      second_section = Section.find_by(title: "Section B")
      second_section.update!(created_at: Time.zone.now - 1.hour)

      # Refresh the page to reload the updated sections
      visit current_path

      within(".app-task-list") do
        section_headings = find_all("h2.app-task-list__section")

        expect(section_headings[0]).to have_content(first_section.title)
        expect(section_headings[1]).to have_content(second_section.title)
      end
    end
  end
end
