# frozen_string_literal: true

#
# A form submission that contacts the case management team
#
class SupportRequest < Request
  belongs_to :user
  belongs_to :category, optional: true
  belongs_to :journey, optional: true
end
