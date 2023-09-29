class CaseRequest::SchoolPicker
  include ActiveModel::Model

  attr_accessor(
    :case_request,
    :school_urns,
  )

  def save!
    case_request.pick_schools(school_urns)
  end
end
