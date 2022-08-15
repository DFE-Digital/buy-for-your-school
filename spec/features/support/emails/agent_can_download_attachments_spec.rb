describe "Agent can download attachments" do
  include_context "with an agent"

  let(:email) { create(:support_email, :inbox, case: support_case, unique_body: "Catering requirements") }
  let(:support_case) { create(:support_case) }

  before do
    create(:support_email_attachment, email:)

    click_button "Agent Login"
    visit support_case_path(support_case)
    click_link "Messages"
    click_link "View"
  end

  it "allows the user to download the attachment" do
    within "#messages" do
      click_link "attachment.txt"
    end

    expect(page).to have_content("This is an attachment for an email")
  end
end
