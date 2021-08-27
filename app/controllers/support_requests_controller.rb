# frozen_string_literal: true

class SupportRequestsController < ApplicationController
  before_action :set_support_request, only: %i[show edit update]
  def new
    @support_request = SupportRequest.new
  end

  def create
    @support_request = SupportRequest.new(support_request_params)
    if @support_request.save
      redirect_to user_support_request_path(current_user, @support_request), notice: "Support request created"
    else
      render :new
    end
  end

  def edit; end

  def update
    if @support_request.update(support_request_params)
      redirect_to user_support_request_path(current_user, @support_request), notice: "Support request updated"
    else
      render :edit
    end
  end

  def show; end

private

  def set_support_request
    @support_request = SupportRequest.find(params[:id])
  end

  def support_request_params
    params.require(:support_request).permit(
      :journey_id, :category_id, :message
    ).merge(user: current_user)
  end
end
