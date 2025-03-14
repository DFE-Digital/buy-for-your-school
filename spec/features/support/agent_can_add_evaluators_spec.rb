require "rails_helper"

describe "Agent can add evaluators", :js do
  include_context "with an agent"

  let(:support_case) { create(:support_case) }

  specify "Adding evaluators" do
    visit support_case_evaluators_path(case_id: support_case)

    click_link "Add"

    fill_in "First name", with: "Momo"
    fill_in "Last name", with: "Taro"
    fill_in "Email address", with: "momotaro@example.com"

    click_button "Save changes"

    expect(page).to have_text("Momo Taro successfully added")
    expect(page).to have_text("momotaro@example.com")

    click_link "Change"

    fill_in "First name", with: "Oni"
    fill_in "Last name", with: "Baba"
    fill_in "Email address", with: "onibaba@example.com"

    click_button "Save changes"

    expect(page).to have_text("Oni Baba successfully updated")
    expect(page).to have_text("onibaba@example.com")

    click_link "Change"
    click_link "Remove"

    expect(page).to have_text("Are you sure you want to remove Oni Baba")

    click_link "Remove"

    expect(page).to have_text("Oni Baba successfully removed")
    expect(page).not_to have_text("onibaba@example.com")
  end
end
