require "rails_helper"

feature "Users can view their existing journeys" do
  before { user_is_signed_in }

  it "displays the page header" do
    visit journeys_path
    expect(page).to have_content(I18n.t("journey.index.existing.header"))
  end

  it "lists existing journeys" do
    create(:journey, created_at: Time.local(2021, 2, 15, 12, 0, 0))
    create(:journey, created_at: Time.local(2021, 3, 20, 12, 0, 0))

    visit journeys_path

    expect(page).to have_content("15 February 2021")
    expect(page).to have_content("20 March 2021")
  end
end
