require "rails_helper"

feature "Users can view a list of sections" do
  let(:user) { create(:user) }

  before { user_is_signed_in(user: user) }

  it "the user can see multiple sections" do
    start_journey_from_category(category: "multiple-sections.json")

    within(".app-task-list") do
      expect(page).to have_content("Section A")
      expect(page).to have_content("Section B")
    end
  end

  context "when sections are saved in a different order than in Contentful" do
    it "the user continues to be shown the order defined by Contentful" do
      start_journey_from_category(category: "multiple-sections.json")

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
