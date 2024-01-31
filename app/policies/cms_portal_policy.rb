class CmsPortalPolicy
  attr_reader :support_agent

  def initialize(support_agent, _scope) = @support_agent = support_agent

  # CMS Portal Access

  def access_legacy_admin? = allow_any_of(%w[global_admin internal analyst])
  def access_statistics? = allow_any_of(%w[global_admin internal procops_admin procops analyst])
  def access_proc_ops_portal? = allow_any_of(%w[global_admin internal procops_admin procops])
  def access_e_and_o_portal? = allow_any_of(%w[global_admin internal e_and_o_admin e_and_o])
  def access_admin_settings? = allow_any_of(%w[global_admin procops_admin e_and_o_admin framework_evaluator_admin])
  def access_establishment_search? = access_proc_ops_portal? || access_e_and_o_portal?
  def access_frameworks_portal? = allow_any_of(%w[global_admin framework_evaluator_admin framework_evaluator procops_admin procops internal])

  # Proof of concepts

  def access_proof_of_concepts? = allow_any_of(%w[global_admin internal])

  # Agent management

  def manage_agents? = allow_any_of(%w[global_admin procops_admin e_and_o_admin])

  # Frameworks management

  def manage_frameworks_register_upload? = allow_any_of(%w[global_admin framework_evaluator_admin])
  def manage_frameworks_activity_log? = allow_any_of(%w[global_admin framework_evaluator_admin])

  # Role management

  def grantable_roles = @grantable_roles ||= Support::Agent::ROLES.select { |role, _label| send("grant_#{role}_role?") }
  def grantable_role_names = grantable_roles.transform_keys(&:to_s).keys

  def grant_global_admin_role? = allow_any_of(%w[global_admin])
  def grant_procops_admin_role? = allow_any_of(%w[global_admin procops_admin])
  def grant_procops_role? = allow_any_of(%w[global_admin procops_admin])
  def grant_e_and_o_admin_role? = allow_any_of(%w[global_admin e_and_o_admin])
  def grant_e_and_o_role? = allow_any_of(%w[global_admin e_and_o_admin])
  def grant_internal_role? = allow_any_of(%w[global_admin])
  def grant_analyst_role? = allow_any_of(%w[global_admin])
  def grant_framework_evaluator_admin_role? = allow_any_of(%w[global_admin])
  def grant_framework_evaluator_role? = allow_any_of(%w[global_admin framework_evaluator_admin])

private

  def allow_any_of(roles) = support_agent.roles.intersection(Array(roles)).any?
end
