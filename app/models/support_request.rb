# frozen_string_literal: true

#
# A form submission that contacts the case management team
#
class SupportRequest < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :category, optional: true
  belongs_to :journey, optional: true
end
