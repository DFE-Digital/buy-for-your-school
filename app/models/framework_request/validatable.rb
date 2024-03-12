module FrameworkRequest::Validatable
  extend ActiveSupport::Concern

  included do
    validates :first_name, presence: true, on: :complete
    validates :last_name, presence: true, on: :complete
    validates :email, presence: true, on: :complete
    validates :org_id, presence: true, on: :complete
    validates :category, presence: true, on: :complete
    validates :procurement_amount, presence: true, on: :complete
    validates :message_body, presence: true, on: :complete
    validates :origin, presence: true, on: :complete
  end
end
