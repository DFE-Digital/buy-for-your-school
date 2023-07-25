#
# "School Business Professional (SBP)" authenticated via "DfE Sign In"
#
class User < ApplicationRecord
  has_many :journeys
  has_many :support_requests, class_name: "SupportRequest"
  belongs_to :support_agent, class_name: "Support::Agent", foreign_key: "dfe_sign_in_uid", primary_key: "dsi_uid", optional: true

  # users belonging to supported organisations
  scope :supported, -> { where("orgs @> any(array[?]::jsonb[])", ORG_TYPE_IDS.map { |id| %([{"type": {"id": "#{id}"}}]) }) }

  # users belonging to unsupported organisations
  scope :unsupported, -> { where.not("orgs @> any(array[?]::jsonb[])", ORG_TYPE_IDS.map { |id| %([{"type": {"id": "#{id}"}}]) }) }

  # users belonging to the proc-ops team
  scope :internal, -> { where("orgs @> ?", %([{"name": "#{ENV['PROC_OPS_TEAM']}"}])) }

  # users who have the "analyst" role
  scope :analysts, -> { where("roles @> ?", %("analyst")) }
  scope :admins, -> { where(admin: true) }

  # @return [false] distinguish from unauthenticated user
  #
  def guest?
    false
  end

  # @see [SessionsController]
  #
  # @return [Boolean] user is an internal team member (or case worker)
  def internal?
    support_agent.present? || proc_ops?
  end

  def proc_ops?
    self.class.internal.include?(self)
  end

  # @return [Boolean] user is an analyst
  def analyst?
    self.class.analysts.include?(self)
  end

  # @return [Boolean] user is not an internal team member or in a supported organisation
  def unsupported?
    self.class.internal.exclude?(self) && self.class.supported.exclude?(self)
  end
end
