#
# "School Business Professional (SBP)" authenticated via "DfE Sign In"
#
class User < ApplicationRecord
  has_many :journeys
  has_many :support_requests, class_name: "SupportRequest"

  # users belonging to supported organisations
  scope :supported, -> { where("orgs @> any(array[?]::jsonb[])", ORG_TYPE_IDS.map { |id| %([{"type": {"id": "#{id}"}}]) }) }

  # users belonging to unsupported organisations
  scope :unsupported, -> { where.not("orgs @> any(array[?]::jsonb[])", ORG_TYPE_IDS.map { |id| %([{"type": {"id": "#{id}"}}]) }) }

  # users belonging to the proc-ops team
  scope :proc_ops, -> { where("orgs @> ?", %([{"name": "#{ENV['PROC_OPS_TEAM']}"}])) }

  # @return [false] distinguish from unauthenticated user
  #
  def guest?
    false
  end

  # @return [Boolean]
  def unsupported?
    User.unsupported.include?(self) && User.proc_ops.exclude?(self)
  end
end
