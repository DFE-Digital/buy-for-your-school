class LocalAuthority < ApplicationRecord
  has_many :organisations, class_name: "Support::Organisation"

  validates :la_code, uniqueness: true
  validates :name, uniqueness: true

  def eligible_for_school_picker?
    organisations.count > 1
  end
end
