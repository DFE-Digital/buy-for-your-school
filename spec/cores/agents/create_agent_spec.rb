require "rails_helper"

describe Agents::CreateAgent do
  subject(:service) { described_class.new }

  it "creates an agent based on the given details" do
    support_agent_details = {
      email: "test@email.com",
      first_name: "Test",
      last_name: "User",
      bad_key_to_be_ingored: "XXX",
    }
    expect { service.call(support_agent_details:) }.to change {
      Support::Agent.where(
        email: support_agent_details[:email],
        first_name: support_agent_details[:first_name],
        last_name: support_agent_details[:last_name],
      ).count
    }.from(0).to(1)
  end
end
