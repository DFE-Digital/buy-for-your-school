class ErrorsController < ApplicationController
  skip_before_action :authenticate_user!

  def internal_server_error
    render "errors/internal_server_error",
           status: :internal_server_error
  end

  def not_found
    render "errors/not_found",
           status: :not_found
  end

  def unacceptable
    render "errors/unacceptable",
           status: :unprocessable_entity
  end
end
