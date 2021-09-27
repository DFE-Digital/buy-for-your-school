# frozen_string_literal: true

#
# A form submission that contacts the case management team
#
class SupportRequest < ApplicationRecord
  belongs_to :user
  belongs_to :category, optional: true
  belongs_to :journey, optional: true

  after_create :submit_support_request

private

  def submit_support_request
    SubmitSupportRequest.new(self).call
  end
end
