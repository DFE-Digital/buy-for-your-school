#
# "School Business Professional (SBP)" authenticated via "DfE Sign In"
#
class User < ApplicationRecord
  has_many :journeys
  has_many :support_requests, class_name: "SupportRequest"

  scope :supported, -> { where("orgs @> any(array[?]::jsonb[]) OR orgs @> ?", ORG_TYPE_IDS.map { |id| %([{"type": {"id": "#{id}"}}]) }, %([{"name": "#{ENV['PROC_OPS_TEAM']}"}])) }

  scope :unsupported, -> { where.not("orgs @> any(array[?]::jsonb[]) OR orgs @> ?", ORG_TYPE_IDS.map { |id| %([{"type": {"id": "#{id}"}}]) }, %([{"name": "#{ENV['PROC_OPS_TEAM']}"}])) }

  # @return [false] distinguish from unauthenticated user
  #
  def guest?
    false
  end

  # @return [Boolean]
  def unsupported?
    User.unsupported.include?(self)
  end
end
