class Support::Case::SchoolPicker
  include ActiveModel::Model

  attr_accessor(
    :support_case,
    :school_urns,
  )

  def save!
    support_case.pick_schools(school_urns)
  end
end
