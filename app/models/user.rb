#
# "School Business Professional (SBP)" authenticated via "DfE Sign In"
#
class User < ApplicationRecord

  has_many :journeys
  has_many :support_requests, class_name: "SupportRequest"

  # @return [false] distinguish from unauthenticated user
  #
  def guest?
    false
  end

end
