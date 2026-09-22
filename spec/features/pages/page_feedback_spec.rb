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

    scenario "user selects Yes for page useful question" do
      within("turbo-frame#page_feedback") do
        click_button "Yes"

        expect(page).to have_content("Help us improve Get help buying for schools")
        expect(page).to have_button("Send")
        expect(page).to have_link("Cancel")
      end
    end

    scenario "user submits feedback first instance" do
      within("turbo-frame#page_feedback") do
        click_button "Yes"

        expect(page).to have_field("page_feedback[feedback]", type: "textarea")
        fill_in "page_feedback[feedback]", with: "This is helpful"
        expect(page).to have_button("Send")

        click_button "Send"
        expect(page).to have_content("Thank you for providing feedback")
      end
    end

    scenario "user selects Yes for page useful question and cancel the form" do
      within("turbo-frame#page_feedback") do
        click_button "Yes"

        expect(page).to have_field("page_feedback[feedback]", type: "textarea")
        expect(page).to have_link("Cancel")

        click_link "Cancel"
        expect(page).to have_content("Do you want to provide feedback?")
      end
    end

    scenario "user selects No for page useful question and No for feedback" do
      within("turbo-frame#page_feedback") do
        click_button "No"

        expect(page).to have_content("Do you want to provide feedback?")
        expect(page).to have_button("Yes")
        expect(page).to have_button("No")

        click_button "No"
        expect(page).to have_content("Thank you for providing feedback")
      end
    end

    scenario "user selects No for page useful and Yes for feedback then cancel" do
      within("turbo-frame#page_feedback") do
        click_button "No"

        expect(page).to have_content("Do you want to provide feedback?")
        click_button "Yes"

        expect(page).to have_content("Help us improve Get help buying for schools")
        click_link "Cancel"

        expect(page).to have_content("Do you want to provide feedback?")
      end
    end

    scenario "user cancel the form and submit form" do
      within("turbo-frame#page_feedback") do
        click_button "No"

        expect(page).to have_content("Do you want to provide feedback?")
        click_button "Yes"

        expect(page).to have_content("Help us improve Get help buying for schools")
        fill_in "page_feedback[feedback]", with: ""
        click_button "Send"

        expect(page).to have_content("Thank you for providing feedback")
      end
    end

    scenario "user submits feedback exceeding the character limit" do
      within("turbo-frame#page_feedback") do
        click_button "Yes"

        fill_in "page_feedback[feedback]", with: "a" * 251
        click_button "Send"

        expect(page).to have_field("page_feedback[feedback]", type: "textarea")
        expect(page).not_to have_content("Thank you for providing feedback")
      end
    end
  end
end
