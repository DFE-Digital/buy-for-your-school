require "rails_helper"

describe Agents::AssignRoles do
  it "updates the roles of an agent to those specified" do
    cms_policy = double("cms_policy", grantable_roles: %i[admin tester other])
    support_agent = create(:support_agent, roles: [])
    support_agent_id = support_agent.id
    new_roles = %w[admin tester]

    expect { described_class.new.call(cms_policy:, support_agent_id:, new_roles:) }.to \
      change { support_agent.reload.roles }.from([]).to(new_roles)
  end

  it "does not override roles I am not eligible to change" do
    cms_policy = double("cms_policy", grantable_roles: %i[admin tester])
    support_agent = create(:support_agent, roles: %w[dont_change tester])
    support_agent_id = support_agent.id
    new_roles = %w[admin]

    expect { described_class.new.call(cms_policy:, support_agent_id:, new_roles:) }.to \
      change { support_agent.reload.roles }.from(%w[dont_change tester]).to(%w[dont_change admin])
  end
end
