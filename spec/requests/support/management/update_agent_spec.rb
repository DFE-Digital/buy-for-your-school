require "rails_helper"

describe "Updating an Agent" do
  describe "updating the roles" do
    before { agent_is_signed_in(roles: %w[procops_admin]) }

    it "updates the roles according the which roles you are able to update" do
      agent_to_update = create(:support_agent, roles: %w[procops_admin procops e_and_o_admin e_and_o])

      patch support_management_agent_path(agent_to_update), params: { agent: { roles: [], first_name: "F", last_name: "L", email: "email@email.com" } }

      agent_to_update.reload
      expect(agent_to_update.roles).to eq(%w[e_and_o_admin e_and_o])
      expect(agent_to_update.first_name).to eq("F")
      expect(agent_to_update.last_name).to eq("L")
      expect(agent_to_update.email).to eq("email@email.com")
    end
  end
end
