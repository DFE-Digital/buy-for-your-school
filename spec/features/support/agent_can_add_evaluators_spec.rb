require "rails_helper"

describe "Agent can add evaluators", :js do
  include_context "with an agent"

  let(:support_case) { create(:support_case) }

  specify "Adding evaluators" do
    visit support_case_evaluators_path(case_id: support_case)

    click_link "Add"

    expect(Support::Interaction.count).to eq(0)

    fill_in "First name", with: "Momo"
    fill_in "Last name", with: "Taro"
    fill_in "Email address", with: "momotaro@example.com"

    click_button "Save changes"

    expect(page).to have_text("Momo Taro successfully added")
    expect(page).to have_text("momotaro@example.com")

    expect(Support::Interaction.count).to eq(1)
    expect(Support::Interaction.last.body).to eq("Evaluator Momo Taro added by Procurement Specialist")

    expect(page).to have_css(".govuk-visually-hidden", text: "Momo Taro")

    click_link "Change"

    fill_in "First name", with: "Oni"
    fill_in "Last name", with: "Baba"
    fill_in "Email address", with: "onibaba@example.com"

    click_button "Save changes"

    expect(page).to have_text("Oni Baba successfully updated")
    expect(page).to have_text("onibaba@example.com")

    expect(Support::Interaction.count).to eq(3)
    expect(Support::Interaction.all[0].body).to eq("Evaluator email for Oni Baba updated by Procurement Specialist")
    expect(Support::Interaction.all[1].body).to eq("Evaluator Momo Taro changed to Oni Baba by Procurement Specialist")

    click_link "Change"
    click_link "Remove"

    expect(page).to have_text("Are you sure you want to remove Oni Baba")

    click_link "Remove"

    expect(page).to have_text("Oni Baba successfully removed")
    expect(page).not_to have_text("onibaba@example.com")

    expect(Support::Interaction.count).to eq(4)
    expect(Support::Interaction.all[0].body).to eq("Evaluator Oni Baba removed by Procurement Specialist")

    visit support_case_path(support_case, anchor: "case-history")
    expect(page).to have_text "Evaluator Momo Taro added by Procurement Specialist"
    expect(page).to have_text "Evaluator email for Oni Baba updated by Procurement Specialist"
    expect(page).to have_text "Evaluator Momo Taro changed to Oni Baba by Procurement Specialist"
    expect(page).to have_text "Evaluator Oni Baba removed by Procurement Specialist"
  end

  specify "Action flag status update when evaluator deletes" do
    support_case.update!(action_required: true, evaluation_due_date: Date.tomorrow, has_uploaded_documents: true)
    support_case.evaluators.create!(first_name: "Momo", last_name: "Taro", email: "email@address", has_uploaded_documents: true, evaluation_approved: true)
    support_case.evaluators.create!(first_name: "Oni", last_name: "Baba", email: "email2@address", has_uploaded_documents: true)

    visit support_case_evaluators_path(case_id: support_case)

    expect(page).to have_text("Evaluators")

    within(".govuk-table__body > tr:nth-child(2)") do
      click_link "Change"
    end

    expect(page).to have_text("Update evaluator details")

    click_link "Remove"

    expect(page).to have_text("Are you sure you want to remove Oni Baba?")

    click_link "Remove"

    expect(page).to have_text("Evaluators")

    support_case.reload

    expect(support_case.action_required).to be(false)
  end
end
