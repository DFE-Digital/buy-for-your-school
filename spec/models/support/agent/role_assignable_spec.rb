require "rails_helper"

describe Support::Agent::RoleAssignable do
  it "updates the roles of an agent to those specified" do
    cms_policy = double("cms_policy", grantable_role_names: %w[admin tester other])
    support_agent = create(:support_agent, roles: [])
    new_roles = %w[admin tester]

    expect { support_agent.assign_roles(new_roles:, using_policy: cms_policy) }.to \
      change { support_agent.reload.roles }.from([]).to(new_roles)
  end

  it "does not override roles I am not eligible to change" do
    cms_policy = double("cms_policy", grantable_role_names: %w[admin tester])
    support_agent = create(:support_agent, roles: %w[dont_change tester])
    new_roles = %w[admin]

    expect { support_agent.assign_roles(new_roles:, using_policy: cms_policy) }.to \
      change { support_agent.reload.roles }.from(%w[dont_change tester]).to(%w[dont_change admin])
  end
end
