# frozen_string_literal: true

class ApplicationController < ActionController::Base
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

  before_action :authenticate_user!, except: :health_check

  protect_from_forgery

  def health_check
    render json: {rails: "OK"}, status: :ok
  end
end
