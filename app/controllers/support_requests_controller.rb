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

  def load_support_request_wizard
    @support_request_wizard = support_wizard_for_step(action_name)
  end

  def support_wizard_for_step(step)
    raise InvalidStep unless step.in?(SupportRequestForm::STEPS)

    "SupportRequestForm::#{step.camelize}".constantize.new(session[:user_attributes])
  end

  def support_wizard_next_step(step)
    SupportRequestForm::STEPS[SupportRequestForm::STEPS.index(step) + 1]
  end

  class InvalidStep < StandardError; end
end
