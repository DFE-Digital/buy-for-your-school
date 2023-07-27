# frozen_string_literal: true

class Specify::SupportRequestsController < Specify::ApplicationController
  before_action :support_request, only: %i[show edit update]
  before_action :form, only: %i[create update]

  def index; end

  def show
    @current_user = UserPresenter.new(current_user)

    if support_request.submitted?
      redirect_to support_request_submission_path(support_request)
    end
  end

  def new
    @form = SupportForm.new(user: current_user)
  end

  def edit
    @form =
      SupportForm.new(
        user: current_user,
        step: params[:step],
        **persisted_data,
      )
  end

  def create
    if validation.success? && validation.to_h[:special_requirements]
      request = SupportRequest.create!(@form.data)
      redirect_to support_request_path(request)
    else

      if back_link?
        @form.backward
      elsif validation.success?
        @form.forward
      end

      render :new
    end
  end

  def update
    if validation.success?
      @form.toggle_subject

      if @form.jump_to_category?
        @form.advance!
        render :edit
      else
        support_request.update!(**persisted_data, **@form.data)

        redirect_to support_request_path(support_request), notice: I18n.t("support_request.flash.updated")
      end

    else
      render :edit
    end
  end

private

  # @return [SupportRequest] restricted to the current user
  def support_request
    @support_request = SupportRequestPresenter.new(SupportRequest.where(user_id: current_user.id, id: params[:id]).first)
  end

  # @return [Hash]
  def persisted_data
    support_request.attributes.symbolize_keys
  end

  # @return [SupportForm] form object populated with validation messages
  def form
    @form ||= SupportForm.new(
      user: current_user,
      step: form_params[:step],
      messages: validation.errors(full: true).to_h,
      **validation.to_h,
    )
  end

  # @return [SupportFormSchema] validated form input
  def validation
    @validation ||= SupportFormSchema.new.call(**form_params)
  end

  # TODO: maybe? - move the form back param into the parent class
  #
  # @return [Boolean]
  def back_link?
    @back_link = form_params[:back].eql?("true")
  end

  def form_params
    params.require(:support_form).permit(*%i[
      step
      phone_number
      journey_id
      category_id
      message_body
      school_urn
      procurement_amount
      special_requirements_choice
      special_requirements
      back
    ])
  end
end
