# frozen_string_literal: true

class SupportRequestsController < ApplicationController
  before_action :set_support_request, only: %i[show edit update]

  def new
    @support_form_wizard = SupportFormWizard.new(step: 1)
  end

  def create
    @support_form_wizard = "SupportFormWizard::Step#{support_form_wizard_params[:step]}"
                             .constantize.new(support_form_wizard_params)

    if @support_form_wizard.save
      if @support_form_wizard.last_step?
        redirect_to user_support_request_path(current_user, @support_form_wizard.support_request),
                    notice: I18n.t("support_request.created_flash")
      else
        render :new
      end
    else
      render :new
    end
  end

  def edit
    @support_form_wizard = "SupportFormWizard::Step#{safe_step}"
                             .constantize.new(journey_id: @support_request.journey_id,
                                              category_id: @support_request.category_id,
                                              phone_number: @support_request.phone_number,
                                              message: @support_request.message,
                                              step: safe_step)
  end

  def update
    if @support_request.update(params_cleaned_up)
      redirect_to user_support_request_path(current_user, @support_request),
                  notice: I18n.t("support_request.updated_flash")
    else
      render :edit
    end
  end

  def show; end

private

  def safe_step
    SupportFormWizard::STEPS.fetch(params[:step].to_i) - 1
  end

  def set_support_request
    @support_request = SupportRequest.find(params[:id])
  end

  def support_form_wizard_params
    params.require(:support_form_wizard).permit(
      :phone_number, :journey_id, :category_id, :message, :step
    ).merge(user: current_user)
  end

  def params_cleaned_up
    params = support_form_wizard_params
    params.delete(:step)
    params
  end
end
