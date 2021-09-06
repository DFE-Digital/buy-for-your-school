# frozen_string_literal: true

class SupportRequestsController < ApplicationController
  before_action :set_support_request, only: %i[show edit update]

  def new
    @support_form_wizard = SupportFormWizard.new
  end

  def create
    @support_form_wizard = "SupportFormWizard::Step#{support_form_wizard_params[:step]}"
                             .constantize.new(support_form_wizard_params)
    
    if @support_form_wizard.save
      if @support_form_wizard.last_step?
        redirect_to user_support_request_path(current_user, @support_form_wizard.support_request),
                    notice: "Support request created"
      else
        render :new
      end
    else
      render :new
    end
  end

  def edit; end

  def update
    if @support_request.update(support_form_wizard_params)
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

  def support_form_wizard_params
    params.require(:support_form_wizard).permit(
      :journey_id, :category_id, :message, :step
    ).merge(user: current_user)
  end
end
