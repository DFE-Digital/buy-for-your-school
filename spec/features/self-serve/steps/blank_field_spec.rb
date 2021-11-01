RSpec.feature "Back link works after failed form validations" do
  let(:user) { create(:user) }
  let(:category) { create(:category, :catering) }
  let(:journey) { create(:journey, user: user, category: category) }
  let(:section) { create(:section, title: "Catering", journey: journey) }

  before do
    user_is_signed_in(user: user)
    task_with_every_kind_of_step = create(:task, title: "Task containing every type of step", section: section)
    create(:step, :long_text, title: "Describe what you need", contentful_id: "contentful-category-entry", task: task_with_every_kind_of_step)

    visit "/journeys/#{journey.id}"
  end

  it "clears the validation error rather than raise a routing error" do
    # TODO: replace fixture with factory
    # start_journey_from_category(category: "section-with-multiple-tasks.json")

    within ".app-task-list" do
      click_on "Task containing every type of step"
    end

    # form validation errors because not answered
    click_continue

    # would raise routing error without routes guard clause
    click_back
    pp page.source

    expect(page).to have_content "Describe what you need"
  end
end
