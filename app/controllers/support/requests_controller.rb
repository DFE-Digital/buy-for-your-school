# frozen_string_literal: true

module Support
  class RequestsController < ApplicationController
    def new
      @current_user.support_requests.build
      @current_user.schools.build
    end

    def create
      if @current_user.update(support_request_params)
        redirect_to @support_request, notice: "Support request was successfully created."
      else
        render :new
      end
    end

    def edit; end

    def show; end

  private

    def set_support_request
      @support_request = SupportRequest.find(params[:id])
    end

    def support_request_params
      params.require(:user).permit(
        :id, :full_name, :email_address, :phone_number, :contact_preferences,
        schools_attributes: %i[name postcode],
        support_requests_attributes: %i[specification_ids category_ids message]
      )
    end
  end
end
