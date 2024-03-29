class Frameworks::ApplicationController < ApplicationController
  include SupportAgents
  before_action :set_back_url

private

  def authorize_agent_scope = :access_frameworks_portal?
  def portal_namespace = :frameworks

  def set_back_url
    @back_url = back_link_param || request.referer
  end
end
