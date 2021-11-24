#
# "School Business Professional (SBP)" authenticated via "DfE Sign In"
#
class User < ApplicationRecord
  has_many :journeys
  has_many :support_requests, class_name: "SupportRequest"

  # TODO: come back to this
  # from supported establishments
  # scope :supported, ->(ids) { where("(data->'type'->>'id' ? :value)::int", value: ids) }

  scope :supported, -> { where("orgs @> any(array[?]::jsonb[])", ORG_TYPE_IDS.map { |id| %([{"type": {"id": "#{id}"}}]) }) }

  # @return [false] distinguish from unauthenticated user
  #
  def guest?
    false
  end
end
