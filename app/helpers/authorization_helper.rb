module AuthorizationHelper
  def grantable_agent_role_options
    policy(:cms_portal).grantable_roles.map do |id, label|
      OpenStruct.new(id: id.to_s, label:)
    end
  end
end
