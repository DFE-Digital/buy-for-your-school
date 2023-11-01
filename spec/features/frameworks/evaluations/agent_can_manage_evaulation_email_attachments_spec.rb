require "rails_helper"

describe "Agent can manage email attachments on an evaluation", js: true do
  include_context "with a framework evaluation agent"

  def attachment_for_ticket(file, type = "text/plain")
    create(:email_attachment, file: fixture_file_upload(file, type), email: create(:email, ticket: evaluation))
  end

  let(:evaluation) { create(:frameworks_evaluation) }

  before do
    attachment_for_ticket("/text-file.txt")
    attachment_for_ticket("/another-text-file.txt")
  end

  it "can edit the name of an email attachment" do
    visit frameworks_evaluation_path(evaluation)
    go_to_tab "Attachments"

    expect(page).to have_content("text-file.txt")
    expect(page).to have_content("another-text-file.txt")

    within "tr", text: "another-text-file.txt" do
      click_on "Edit"
    end
    fill_in "File name", with: "NewFile"
    click_on "Save"

    expect(page).to have_content("text-file.txt")
    expect(page).to have_content("NewFile.txt")
  end

  it "can hide an email attachment" do
    visit frameworks_evaluation_path(evaluation)
    go_to_tab "Attachments"

    within "tr", text: "another-text-file.txt" do
      accept_confirm do
        click_on "Hide"
      end
    end

    expect(page).to have_content("text-file.txt")
    expect(page).not_to have_content("another-text-file.txt")
  end
end
