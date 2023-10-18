describe "Agent can download attachments", js: true do
  include_context "with an agent"

  let(:email) { create(:support_email, :inbox, ticket: support_case, unique_body: "Catering requirements") }
  let(:support_case) { create(:support_case) }

  before do
    create(:support_email_attachment, email:)

    visit support_case_path(support_case)
    click_link "Messages"
    within("#messages-frame") { click_link "View" }
  end

  it "allows the user to download the attachment" do
    attachment_window = window_opened_by { within("#messages-frame") { click_link "attachment.txt" } }
    within_window(attachment_window) { expect(page).to have_content("This is an attachment for an email") }
  end
end
