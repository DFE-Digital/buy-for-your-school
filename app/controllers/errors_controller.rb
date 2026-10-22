class ErrorsController < ApplicationController
  layout "homepage"

  before_action :set_back_link
  skip_before_action :authenticate_user!

  def internal_server_error
    render "errors/internal_server_error",
           formats: [:html],
           status: :internal_server_error
  end

  def not_acceptable
    render "errors/unacceptable",
           formats: [:html],
           status: :not_acceptable
  end

  def not_found
    render "errors/not_found",
           formats: [:html],
           status: :not_found
  end

  def unacceptable
    render "errors/unacceptable",
           formats: [:html],
           status: :unprocessable_entity
  end

private

  def set_back_link
    @page_back_link = request.referer || root_path
  end
end
