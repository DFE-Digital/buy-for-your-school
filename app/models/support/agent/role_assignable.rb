module Support::Agent::RoleAssignable
  extend ActiveSupport::Concern

  ROLES = {
    global_admin: "Global Administrator",
    procops_admin: "Procurement Operations Admin",
    procops: "Procurement Operations Staff Member",
    e_and_o_admin: "Engagement and Outreach Admin",
    e_and_o: "Engagement and Outreach Staff Member",
    internal: "Digital Team Staff Member",
    analyst: "Data Analyst",
    framework_evaluator: "Framework Evaluator",
    framework_evaluator_admin: "Framework Evaluator Admin",
  }.freeze

  included do
    scope :by_role, ->(roles) { where("ARRAY[?] && roles::text[]", Array(roles)) }
    scope :caseworkers, -> { by_role(%w[procops procops_admin]) }
    scope :e_and_o_staff, -> { by_role(%w[e_and_o e_and_o_admin]) }
    scope :framework_evaluators, lambda {
      by_role(%w[
        procops_admin
        procops
        framework_evaluator
        framework_evaluator_admin
      ])
    }
  end

  def assign_roles(new_roles:, using_policy:)
    removed = using_policy.grantable_role_names & (roles - new_roles)
    added   = using_policy.grantable_role_names & new_roles

    update!(roles: (roles - removed + added).uniq)
  end

  def labelled_roles = roles.map { |role| ROLES[role.to_sym] }
end
