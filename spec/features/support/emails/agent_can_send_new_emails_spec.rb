describe "Agent can send new emails" do
  include_context "with an agent"

  let(:support_case) { create(:support_case) }

  before do
    click_button "Agent Login"
    visit support_case_path(support_case)
    click_on "Messages"
  end

  context "when there are no emails from the school" do
    it "shows the email text box in the messages tab" do
      expect(page).to have_field "Your message"
    end
  end
end
