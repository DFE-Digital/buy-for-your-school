RSpec.feature "Case Management Dashboard - resolve case" do
  let(:agent) { create(:support_agent) }
  let(:support_case) { create(:support_case, state: "open", agent: agent) }

  before do
    user_is_signed_in
    visit "/support/cases/#{support_case.id}"
    click_link "Resolve case"
  end

  it "displays a text area" do
    expect(find("textarea.govuk-textarea")).to be_visible
  end

  it "displays a submit button" do
    expect(find_button("Save and close case")).to be_visible
  end

  context "when submitting the form" do
    before do
      fill_in "support_case[resolve_message]", with: "this is an example note"
      click_on "Save and close case"
    end

    it "redirects to the case in question" do
      expect(page).to have_a_support_case_path
    end

    it "marks the case as resolved" do
      expect(support_case.reload.state).to eq("resolved")
    end

    it "unassigns the agent" do
      expect(support_case.reload.agent).to be_nil
    end
  end
end
