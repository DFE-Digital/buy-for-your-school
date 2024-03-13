RSpec.shared_context "with an agent" do |roles: %w[procops]|
  let(:given_roles) { roles }
  let(:user) { create(:user, :caseworker) }
  let!(:agent) { Support::Agent.find_or_create_by_user(user).tap { |agent| agent.update!(roles: given_roles) } }

  #
  # Provided a caseworker is added to the DSI organisation
  # when they go to the supported buying application
  # and click the "Agent Login" button
  # they will be permitted to enter
  #
  before do
    Current.actor = agent
    user_exists_in_dfe_sign_in(user:)
    visit "/"
    click_start
  end
end

RSpec.shared_context "with a framework evaluation agent" do
  include_context "with an agent", roles: %i[procops framework_evaluator]
end
