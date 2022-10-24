RSpec.shared_context "with an agent" do
  around do |example|
    ClimateControl.modify(PROC_OPS_TEAM: "DSI Caseworkers") do
      example.run
    end
  end

  let(:user) { create(:user, :caseworker) }
  let(:agent) { Support::Agent.find_by(email: user.email) }

  #
  # Provided a caseworker is added to the DSI organisation
  # when they go to the supported buying application
  # and click the "Agent Login" button
  # they will be permitted to enter
  #
  before do
    user_exists_in_dfe_sign_in(user:)
    visit "/"
    click_start
    visit "/support"
  end
end
