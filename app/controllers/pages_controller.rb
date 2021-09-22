class PagesController < ApplicationController
  include HighVoltage::StaticPage

  skip_before_action :authenticate_user!

  # TODO: remove this once pages are dynmaic
  def self.dsi?
    Rails.env.development? && (ENV["DFE_SIGN_IN_ENABLED"] == "false")
  end

  def planning_start_page
    @back_url = root_path
  end
end
