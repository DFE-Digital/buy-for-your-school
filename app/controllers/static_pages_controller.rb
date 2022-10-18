class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!

  def show
    render params[:page]
  rescue ActionView::MissingTemplate
    render "errors/not_found"
  end
end
