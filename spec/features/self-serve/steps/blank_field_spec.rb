RSpec.feature "Back link works after failed form validations" do
  let(:user) { create(:user) }
  let(:category) { create(:category, :catering, contentful_id: "contentful-category-entry") }
  let(:journey) { create(:journey, user:, category:) }
  let(:section) { create(:section, title: "Catering", journey:, contentful_id: "contentful-section-entry") }

  before do
    user_is_signed_in(user:)
  end

  context "when there is a task containing every type of step" do
    before do
      task_with_every_type_of_step = create(:task, title: "Task containing every type of step", section:)
      create(:step, :long_text, title: "Describe what you need", task: task_with_every_type_of_step, order: 0)
      create(:step, :short_text, title: "What email address did you use?", task: task_with_every_type_of_step, order: 1)
      create(:step, :checkbox, title: "Everyday services that are required and need to be considered", options: [{ "value" => "Breakfast" }], task: task_with_every_type_of_step, order: 2)
      create(:step, :radio, title: "Which service do you need?", options: [{ "value" => "Catering" }], task: task_with_every_type_of_step, order: 3)

      visit "/journeys/#{journey.id}"
    end

    it "clears the validation error rather than raise a routing error" do
      within ".app-task-list" do
        click_on "Task containing every type of step"
      end

      # form validation errors because not answered
      click_continue

      # would raise routing error without routes guard clause
      click_back

      expect(page).to have_content "Describe what you need"
    end
  end
end
