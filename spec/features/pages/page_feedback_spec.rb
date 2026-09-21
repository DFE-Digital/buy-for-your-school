require "rails_helper"

RSpec.describe "Page feedback", :js do
  before do
    allow(FABS::Category).to receive(:all).and_return([])
    allow(Offer).to receive(:featured_offers).and_return([])
    allow(Banner).to receive(:find_by_slug).and_return(nil)
  end

  context "when visiting the homepage" do
    before do
      visit root_path
    end

    scenario "user sees the feedback question" do
      expect(page).to have_content("Is this page useful?")
      expect(page).to have_button("Yes")
      expect(page).to have_button("No")
    end

    scenario "user selects Yes without a full page reload" do
      within("turbo-frame#page_feedback") do
        click_button "No"

        expect(page).to have_content("Do you want to provide feedback?")
      end
    end
  end
end
