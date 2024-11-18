class LocalAuthority < ApplicationRecord
  has_many :organisations, class_name: "Support::Organisation"

  validates :la_code, uniqueness: true
  validates :name, uniqueness: true

  def eligible_for_school_picker?
    organisations_for_multi_school_picker.count > 1
  end

  def organisations_for_multi_school_picker
    organisations.local_authority_maintained.where.not(archived: true)
  end

  def org_type
    "Local authority"
  end
end
