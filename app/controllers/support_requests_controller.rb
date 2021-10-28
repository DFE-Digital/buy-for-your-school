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
    @support_form = SupportForm.new(step: params.fetch(:step, 1))
  end

  def edit
    @support_form = SupportForm.new(step: params[:step], **support_request.attributes.symbolize_keys)
  end

  # questions 2 onwards until complete
  def create
    @support_form = form

    if validation.success? && validation.to_h[:message_body]
      create_and_redirect_to_support_request
    elsif validation.success?
      navigate_through_form(@support_form)

      render :new
    else
      render :new
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

  # TODO: replace this logic when more suitable mechanism is merged
  # NOTE: reek ignores added, multiple calls were necessary - this will be refactored
  # upon merging of MultiStepForm
  def navigate_through_form(support_form)
    # :reek:FeatureEnvy
    if support_form.step == 1 && supported_schools.size == 1
      # :reek:DuplicateMethodCall
      support_form.advance!
    end

    # :reek:FeatureEnvy
    if support_form.step == 2 && current_user.journeys.none?
      # :reek:DuplicateMethodCall
      support_form.advance!
    end

    # :reek:FeatureEnvy
    if support_form.step == 3 && support_form.has_journey?
      # :reek:DuplicateMethodCall
      support_form.advance!
    end

    # :reek:DuplicateMethodCall
    support_form.advance!
  end

  def create_and_redirect_to_support_request
    support_request = SupportRequest.create!(user_id: current_user.id, **validation.to_h)

    if support_request.school_urn.blank? && supported_schools.size == 1
      support_request.update!(school_urn: supported_schools.first.urn)
    end

    redirect_to support_request_path(support_request)
  end

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

  def form_params
    params.require(:support_form).permit(*%i[
      step phone_number journey_id category_id message_body school_urn
    ])
  end

  def supported_schools
    @supported_schools ||= current_user.supported_schools
  end
end
