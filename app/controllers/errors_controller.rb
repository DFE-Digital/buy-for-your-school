class ErrorsController < ApplicationController
  skip_before_action :authenticate_user!

  def internal_server_error
    render "errors/internal_server_error",
      status: 500
  end

  def not_found
    render "errors/not_found",
      status: 404
  end

  def unacceptable
    render "errors/unacceptable",
      status: 422
  end
end
