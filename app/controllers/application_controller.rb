# frozen_string_literal: true

class ApplicationController < ActionController::Base
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

  def health_check
    render json: {rails: "OK"}, status: :ok
  end
end
