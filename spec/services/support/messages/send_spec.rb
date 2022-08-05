RSpec.describe Support::Messages::Send do
  subject(:service) { described_class }

  let(:kase) { create(:support_case) }
  let(:agent) { create(:support_agent, first_name: "Test", last_name: "Agent") }

  let(:params) do
    {
      body: "This is a test message",
      kase:,
      agent: Support::AgentPresenter.new(agent),
    }
  end

  before do
    service.new(**params).call
  end

  it "creates an email record with templated body" do
    email = Support::Email.first
    expect(email.body).to eq "<p>This is a test message</p>\n<p>Regards<br>Test Agent<br>Procurement Specialist<br>Get help buying for schools</p>\n"
  end

  it "creates an email_to_school interaction record" do
    interaction = Support::Interaction.first
    expect(interaction.body).to eq "<p>This is a test message</p>\n<p>Regards<br>Test Agent<br>Procurement Specialist<br>Get help buying for schools</p>\n"
    expect(interaction.event_type).to eq "email_to_school"
  end
end
