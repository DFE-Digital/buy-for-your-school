# A User may have many {Journey}s.
# A User may have many Support Request(s)
class User < ApplicationRecord
  has_many :journeys

  has_many :support_requests, class_name: "SupportRequest"
  accepts_nested_attributes_for :support_requests
end
