RSpec.feature "Back link works after failed form validations" do
  let(:user) { create(:user) }

  before { user_is_signed_in(user: user) }

  it "clears the validation error rather than raise a routing error" do
    # TODO: replace fixture with factory
    start_journey_from_category(category: "section-with-multiple-tasks.json")

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
