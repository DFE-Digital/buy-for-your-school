# frozen_string_literal: true

class SupportRequestsController < ApplicationController
  before_action :support_request, only: %i[show edit update]

  # start the support process
  def index; end

  # check your answers before submission
  def show
    if support_request.submitted?
      redirect_to support_request_submission_path(support_request)
    end
  end

  # first question
  def new
    if params.fetch(:step, 1) == 1
      first_step = if current_user.supported_schools.one?
                     current_user.active_journeys.any? ? 3 : 4
                   else
                     2
                   end

      @support_form = SupportForm.new(school_urn: current_user.school_urn, step: first_step)
    else
      @support_form = SupportForm.new(step: params[:step])
    end
  end

  def edit
    @support_form = SupportForm.new(step: params[:step], **support_request.attributes.symbolize_keys)
  end

  # questions 2 onwards until complete
  def create
    @support_form = form

    if form_params[:back] == "true"
      revert_unpersisted_form

      render :new
    else
      advance_unpersisted_form
    end
  end

  # all questions
  def update
    @support_form = form

    if validation.success?

      if @support_form.step == 3 && @support_form.has_journey?
        @support_form.forget_category!
      elsif @support_form.step == 4 && @support_form.has_category?
        @support_form.forget_journey!
      end

      if @support_form.step == 3 && !@support_form.has_journey?
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
    @support_request = SupportRequestPresenter.new(SupportRequest.where(user_id: current_user.id, id: params[:id]).first)
  end

  # @return [SupportForm] form object populated with validation messages
  def form
    SupportForm.new(step: form_params[:step], messages: validation.errors(full: true).to_h, **validation.to_h)
  end

  # @return [SupportFormSchema] validated form input
  def validation
    SupportFormSchema.new.call(**form_params)
  end

  def advance_unpersisted_form
    if validation.success? && validation.to_h[:message_body]
      support_request = SupportRequest.create!(user_id: current_user.id, **validation.to_h)
      redirect_to support_request_path(support_request)

    elsif validation.success?

      if @support_form.step == 2 && current_user.active_journeys.none?
        @support_form.advance!(2)

      # journey (3) -> message (5)
      elsif @support_form.step == 3 && @support_form.has_journey?
        @support_form.advance!(2)
      else
        @support_form.advance!
      end

      render :new
    else
      render :new
    end
  end

  def revert_unpersisted_form
    if @support_form.step == 4 && current_user.active_journeys.none?
      @support_form.back!(2)
    elsif @support_form.step == 5 && @support_form.has_journey?
      @support_form.back!(2)
    else
      @support_form.back!
    end
  end

  def form_params
    params.require(:support_form).permit(*%i[
      step phone_number journey_id category_id message_body school_urn back
    ])
  end
end
