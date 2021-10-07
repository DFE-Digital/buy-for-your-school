# frozen_string_literal: true

class SupportRequestsController < ApplicationController
  before_action :support_request, only: %i[show edit update]

  # start the support process
  def index; end

  # check your answers before submission
  def show; end

  # first question
  def new
    pending_support_requests = current_user.support_requests.pending

    if pending_support_requests.any?
      redirect_to support_request_path(pending_support_requests.first)
    else
    @support_form = SupportForm.new(step: params.fetch(:step, 1))
    end
  end

  def edit
    @support_form = SupportForm.new(step: params[:step], **support_request.attributes.symbolize_keys)
  end

  # questions 2 onwards until complete
  def create
    @support_form = form

    if validation.success? && validation.to_h[:message_body]

      support_request = SupportRequest.create!(user_id: current_user.id, **validation.to_h)
      redirect_to support_request_path(support_request)

    elsif validation.success?

      if @support_form.step == 1 && current_user.journeys.none?
        @support_form.skip!
      elsif @support_form.step == 2 && @support_form.has_journey?
        @support_form.skip!
      else
        @support_form.advance!
      end

      render :new
    else
      render :new
    end
  end

  # all questions
  def update
    @support_form = form

    if validation.success?

      if @support_form.step == 2 && @support_form.has_journey?
        @support_form.forget_category!
      elsif @support_form.step == 3 && @support_form.has_category?
        @support_form.forget_journey!
      end

      if @support_form.step == 2 && !@support_form.has_journey?
        @support_form.advance!
        render :edit
      else
        support_request.update!(**support_request.attributes.symbolize_keys, **@support_form.to_h)

        redirect_to support_request_path(support_request), notice: I18n.t("support_request.flash.updated")
      end

    else
      render :edit
    end
  end

private

  # @return [UserPresenter] adds form view logic
  def current_user
    @current_user = UserPresenter.new(super)
  end

  # @return [SupportRequest] restricted to the current user
  def support_request
    @support_request = SupportRequest.where(user_id: current_user.id, id: params[:id]).first
  end

  # @return [SupportForm] form object populated with validation messages
  def form
    SupportForm.new(step: form_params[:step], messages: validation.errors(full: true).to_h, **validation.to_h)
  end

  # @return [SupportFormSchema] validated form input
  def validation
    SupportFormSchema.new.call(**form_params)
  end

  def form_params
    params.require(:support_form).permit(*%i[
      step phone_number journey_id category_id message_body
    ])
  end
end
