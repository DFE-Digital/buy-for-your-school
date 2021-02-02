require "rails_helper"

feature "Users can see how to resume a journey" do
  context "on the task list" do
    let(:journey) { create(:journey) }
    scenario "displays the notification banner" do
      visit journey_path(journey)
      expect(page).to have_content(I18n.t("resume.notification.title"))
    end
    scenario "displays the journey URL" do
      visit journey_path(journey)
      expect(page).to have_content(journey_url(journey))
    end
  end
end
