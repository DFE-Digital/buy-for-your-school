module Agents
  class AssignRoles
    def call(support_agent_id:, new_roles:, cms_policy:)
      agent = Support::Agent.find(support_agent_id)
      agent.update!(roles: safe_assign_new_roles(existing_roles: agent.roles, new_roles:, cms_policy:))
    end

  private

    def safe_assign_new_roles(existing_roles:, new_roles:, cms_policy:)
      # find the roles current agent is ineligible to edit
      existing_roles_minus_those_eligible_to_grant = existing_roles.reject { |role| role.to_sym.in?(cms_policy.grantable_roles) }

      # of the roles to change, find the ones the current agent is eligible to grant
      new_roles_eligible_to_grant = new_roles.select { |role| role.to_sym.in?(cms_policy.grantable_roles) }

      # combine
      existing_roles_minus_those_eligible_to_grant + new_roles_eligible_to_grant
    end
  end
end
