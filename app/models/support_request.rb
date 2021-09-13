# frozen_string_literal: true

# A SupportRequest belongs to {User}
# A SupportRequest optionally belongs to {Category}
# A SupportRequest optionally belongs to {Journey}
class SupportRequest < ApplicationRecord
  belongs_to :user
  belongs_to :category, optional: true
  belongs_to :journey, optional: true

  # Validations can be removed here and just used in form object
  validates :message, presence: true
  validates :phone_number, presence: true

# after_create :create_support_enquiry

private

  def create_support_enquiry
    CreateSupportEnquiry.new(self).call
  end
end
