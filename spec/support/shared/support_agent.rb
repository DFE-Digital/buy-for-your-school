RSpec.shared_context "with an agent" do
  around do |example|
    ClimateControl.modify(PROC_OPS_TEAM: "DSI Caseworkers") do
      example.run
    end
  end

  let(:org_name) { "DSI Caseworkers" }

  let(:user) do
    build(:user,
          email: "ops@education.gov.uk",
          first_name: "Procurement",
          last_name: "Specialist")
  end

  let(:agent) do
    Support::Agent.find_by(email: "ops@education.gov.uk")
  end

  #
  # Provided a caseworker is added to the DSI organisation
  # when they go to the supported buying application
  # and click the "Agent Login" button
  # they will be permitted to enter
  #
  before do
    dsi_client = instance_double(::Dsi::Client)
    allow(Dsi::Client).to receive(:new).and_return(dsi_client)
    # allow(dsi_client).to receive(:roles).and_return([])
    allow(dsi_client).to receive(:orgs).and_return([{ "name" => org_name }])

    user_exists_in_dfe_sign_in(user: user)
    visit "/"
    click_start
    visit "/support"
  end
end
