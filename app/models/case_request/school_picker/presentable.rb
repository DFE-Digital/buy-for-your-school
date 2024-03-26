module CaseRequest::SchoolPicker::Presentable
  extend ActiveSupport::Concern

  def organisation_type
    case case_request.organisation_type
    when "Support::EstablishmentGroup" then "academy trust or federation"
    when "LocalAuthority" then "local authority"
    end
  end
end
