class FafController < ApplicationController
  skip_before_action :authenticate_user!

  def new; end

  def dsi_or_search; end

  def create
    render plain: "dsi: #{params[:dsi]}"
  end
end
