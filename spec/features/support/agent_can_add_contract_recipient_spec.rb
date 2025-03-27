require "rails_helper"

describe "Agent can add contract recipient", :js do
  include_context "with an agent"

  let(:support_case) { create(:support_case) }

  def fill_in_recipient_details(first_name:, last_name:, email:)
    fill_in "First name", with: first_name
    fill_in "Last name", with: last_name
    fill_in "Email address", with: email
  end

  specify "Adding contract recipient" do
    visit support_case_contract_recipients_path(case_id: support_case)

    click_link "Add"

    fill_in_recipient_details(first_name: "Momo", last_name: "Taro", email: "momotaro@example.com")

    click_button "Save changes"

    expect(page).to have_text("Momo Taro successfully added")
    expect(page).to have_text("momotaro@example.com")

    expect(Support::Interaction.count).to eq(1)
    expect(Support::Interaction.last.body).to eq("Recipient Momo Taro added by Procurement Specialist")

    expect(page).to have_css(".govuk-visually-hidden", text: "Momo Taro")

    click_link "Change"

    fill_in_recipient_details(first_name: "Oni", last_name: "Baba", email: "onibaba@example.com")

    click_button "Save changes"

    expect(page).to have_text("Oni Baba successfully updated")
    expect(page).to have_text("onibaba@example.com")

    expect(Support::Interaction.count).to eq(3)
    expect(Support::Interaction.all[0].body).to eq("Recipient email for Oni Baba updated by Procurement Specialist")
    expect(Support::Interaction.all[1].body).to eq("Recipient Momo Taro changed to Oni Baba by Procurement Specialist")

    click_link "Change"
    click_link "Remove"

    expect(page).to have_text("Are you sure you want to remove Oni Baba")

    click_link "Remove"

    expect(page).to have_text("Oni Baba successfully removed")
    expect(page).not_to have_text("onibaba@example.com")

    expect(Support::Interaction.count).to eq(4)
    expect(Support::Interaction.first.body).to eq("Recipient Oni Baba removed by Procurement Specialist")
  end
end
