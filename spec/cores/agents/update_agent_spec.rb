require "rails_helper"

describe Agents::UpdateAgent do
  subject(:service) { described_class.new }

  it "updates an agent based on the given details" do
    support_agent = create(:support_agent, email: "test@email.zom", first_name: "Zest", last_name: "Zser")
    support_agent_details = {
      email: "test@email.com",
      first_name: "Test",
      last_name: "User",
      bad_key_to_be_ingored: "XXX",
    }
    expect { service.call(support_agent_id: support_agent.id, support_agent_details:) }.to \
      change { support_agent.reload.first_name }.from("Zest").to("Test")
      .and change { support_agent.reload.last_name }.from("Zser").to("User")
      .and change { support_agent.reload.email }.from("test@email.zom").to("test@email.com")
  end
end
