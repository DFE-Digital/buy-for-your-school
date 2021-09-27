# frozen_string_literal: true

class SupportRequestsController < ApplicationController
  before_action :set_support_request, only: %i[show edit update]

  def show; end

  def new
    @support_form = SupportForm.new(step: 1)
    # @support_form = SupportForm::Step1.new(step: 1)
  end

  def create
    form_class = "SupportForm::Step#{form_params[:step]}".constantize
    @support_form = form_class.new(form_params)

    if @support_form.save
      if @support_form.last_step?
        redirect_to user_support_request_path(current_user, @support_form.support_request),
                    notice: I18n.t("support_request.created_flash")
      else
        render :new
      end
    else
      render :new
    end
  end

  def edit
    form_class = "SupportForm::Step#{safe_step}".constantize
    @support_form = form_class.new(step: safe_step,
                                   journey_id: @support_request.journey_id,
                                   category_id: @support_request.category_id,
                                   phone_number: @support_request.phone_number,
                                   message: @support_request.message)
  end

  def update
    if @support_request.update(form_params.except(:step))

      redirect_to user_support_request_path(current_user, @support_request),
                  notice: I18n.t("support_request.updated_flash")
    else
      render :edit
    end
  end

private

  def safe_step
    SupportForm::STEPS.fetch(params[:step].to_i) - 1
  end

  def set_support_request
    @support_request = SupportRequest.find(params[:id])
  end

  # @return [ActionController::Parameters] get request attribute names
  #
  def form_params
    params.require(:support_form).permit(
      :phone_number, :journey_id, :category_id, :message, :step
    ).merge(user: current_user)
  end
end
