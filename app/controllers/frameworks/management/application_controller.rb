class Frameworks::Management::ApplicationController < Frameworks::ApplicationController
private

  def authorize_agent_scope = [super, :access_admin_settings?]
end
