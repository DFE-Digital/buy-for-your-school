require "rails_helper"

feature "Users can view their existing journeys" do
  before { user_is_signed_in }

  it "lists existing journeys" do
    user = create(:user)
    user_is_signed_in(user: user)
    create(:journey, user: user, created_at: Time.zone.local(2021, 2, 15, 12, 0, 0))
    create(:journey, user: user, created_at: Time.zone.local(2021, 3, 20, 12, 0, 0))

    visit dashboard_path

    expect(page).to have_content("15 February 2021")
    expect(page).to have_content("20 March 2021")
  end

  context "when the journey does not belong to the user" do
    scenario "that journey is not shown" do
      travel_to Time.zone.local(2021, 2, 15, 12, 0, 0)

      another_user = create(:user)
      _another_users_journey = create(:journey,
                                      user: another_user,
                                      created_at: Time.zone.local(2021, 3, 20, 12, 0, 0))

      signed_in_user = create(:user)
      user_is_signed_in(user: signed_in_user)

      # Start the journey which creates a journey record
      start_journey_from_category(category: "radio-question.json")

      click_on(I18n.t("generic.button.back"))

      expect(page).to have_content("15 February 2021")
      expect(page).not_to have_content("20 March 2021")
    end
  end
end
