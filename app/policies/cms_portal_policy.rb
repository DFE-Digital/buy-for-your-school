class CmsPortalPolicy
  include Rails.application.routes.url_helpers

  attr_reader :support_agent

  def initialize(support_agent, _scope) = @support_agent = support_agent

  def access_legacy_admin? = allow_any_of(%w[global_admin internal analyst])
  def access_statistics? = allow_any_of(%w[global_admin internal procops_admin procops analyst])
  def access_proc_ops_portal? = allow_any_of(%w[global_admin internal procops_admin procops])
  def access_e_and_o_portal? = allow_any_of(%w[global_admin internal e_and_o_admin e_and_o])
  def access_admin_settings? = allow_any_of(%w[global_admin procops_admin e_and_o_admin])

  def grantable_roles = @grantable_roles ||= Support::Agent::ROLES.select { |role, _label| send("grant_#{role}_role?") }

  def grant_global_admin_role? = allow_any_of(%w[global_admin])
  def grant_procops_admin_role? = allow_any_of(%w[global_admin procops_admin])
  def grant_procops_role? = allow_any_of(%w[global_admin procops_admin])
  def grant_e_and_o_admin_role? = allow_any_of(%w[global_admin e_and_o_admin])
  def grant_e_and_o_role? = allow_any_of(%w[global_admin e_and_o_admin])
  def grant_internal_role? = allow_any_of(%w[global_admin])
  def grant_analyst_role? = allow_any_of(%w[global_admin])

private

  def allow_any_of(roles) = support_agent.roles.intersection(Array(roles)).any?
end
