RSpec.feature "Case worker authentication" do
  let(:uuid) { "101" }

  let(:user) do
    build(:user,
          dfe_sign_in_uid: uuid,
          email: "ops@education.gov.uk",
          first_name: "Procurement",
          last_name: "Specialist")
  end

  #
  # Provided a case worker authenticates via the front page
  # and has a whitelisted uuid/email
  # when they go to the supported buying application
  # and click the "Agent Login" button
  # they will be permitted to enter
  #
  before do
    user_exists_in_dfe_sign_in(user: user)
    visit "/"
    click_start
    visit "/support"
  end

  it "has a title" do
    expect(page).to have_title "Supported Buying Case Management"
  end

  it "has a heading" do
    expect(find("h1.govuk-heading-xl")).to have_text "Supported Buying Case Management"
  end

  context "when the agent is whitelisted" do
    it "authenticates" do
      click_button "Agent Login"

      expect(page).to have_current_path "/support/cases"
    end
  end

  context "when the agent is not whitelisted" do
    let(:uuid) { "103" }

    it "fails to gain access" do
      click_button "Agent Login"

      expect(page).not_to have_current_path "/support/cases"
      expect(page).to have_current_path "/support"
    end
  end
end
