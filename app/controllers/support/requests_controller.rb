# frozen_string_literal: true

module Support
  class RequestsController < ApplicationController
    def new
      @support_request = SupportRequest.new(user: current_user)
      @support_request.build_school
    end

    def create
      @support_request = SupportRequest.new(support_request_params)
      @support_request.user.dfe_sign_in_uid = current_user.dfe_sign_in_uid
      if @support_request.save
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
      params.require(:support_request).permit(
        :specification_ids, :category_ids, :message,
        user_attributes: %i[full_name email_address phone_number contact_preferences],
        school_attributes: %i[name postcode]
      )
    end
  end
end
