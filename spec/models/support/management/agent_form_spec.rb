RSpec.describe Support::Management::AgentForm, type: :model do
  let(:cms_policy) do
    double("cms_policy", grantable_role_names: %w[admin tester other])
  end

  it "updates the roles of an agent to those specified" do
    support_agent = create(:support_agent, roles: [])
    new_roles = %w[admin tester]
    form = described_class.find(support_agent.id)

    expect { form.update!(roles: new_roles, policy: cms_policy) }
    .to change { support_agent.reload.roles }
    .from([])
    .to(new_roles)
  end

  it "does not override roles I am not eligible to change" do
    support_agent = create(:support_agent, roles: %w[dont_change tester])
    new_roles = %w[admin]
    form = described_class.find(support_agent.id)

    expect { form.update!(roles: new_roles, policy: cms_policy) }
    .to change { support_agent.reload.roles }
    .from(%w[dont_change tester])
    .to(%w[dont_change admin])
  end
end
