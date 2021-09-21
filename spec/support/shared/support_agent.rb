RSpec.shared_context "with an agent" do
  let(:user) do
    build(:user,
          dfe_sign_in_uid: "101",
          email: "ops@education.gov.uk",
          first_name: "Procurement",
          last_name: "Specialist")
  end

  let(:agent) do
    Support::Agent.find_by(dsi_uid: "101")
  end

  before do
    user_exists_in_dfe_sign_in(user: user)
    visit "/"
    click_start
    visit "/support"
    click_button "Agent Login"
  end
end
