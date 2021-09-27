# frozen_string_literal: true

class SupportRequestsController < ApplicationController

  # class ErrorSummaryUpperCasePresenter
  #   def initialize(error_messages)
  #     @error_messages = error_messages
  #   end

  #   def formatted_error_messages
  #     @error_messages.map { |attribute, messages| [attribute, messages.first.upcase] }
  #   end
  # end


  before_action :support_request, only: %i[show edit update]

  # start the process
  def index
  end

  # check your answers before submission
  def show
  end

  # first question
  def new
    @support_form = SupportForm.new(step: params.fetch(:step, 1))
  end

  # questions 2 onwards until complete
  def create

    # validation
    validation = SupportFormSchema.new.call(**form_params)

    # form
    @support_form = SupportForm.new(step: form_params[:step], messages: validation.errors(full: true).to_h, **validation.to_h)

    if validation.success? && validation.to_h[:message_body]

      support_request = SupportRequest.create(user: current_user, **validation.to_h)

      redirect_to support_request_path(support_request)

    elsif validation.success?


      if (@support_form.step == 2 && @support_form.journey?)
        @support_form.skip!
      else
        @support_form.advance!
      end

      render :new
    else
      render :new
    end
  end


  def edit
    @support_form = SupportForm.new(step: params[:step], **support_request.attributes.symbolize_keys)
  end


  def update


    validation = SupportFormSchema.new.call(**form_params)

    @support_form = SupportForm.new(step: form_params[:step], messages: validation.errors(full: true).to_h, **validation.to_h)


    if validation.success?

      if (@support_form.step == 2 && @support_form.journey?)

        @support_form.forget_category!

        support_request.update(**support_request.attributes.symbolize_keys, **@support_form.to_h)
        redirect_to support_request_path(support_request)

      elsif (@support_form.step == 2 && !@support_form.journey?)

        @support_form.advance!
        render :edit

      elsif (@support_form.step == 3 && !@support_form.category_id.nil?)
        @support_form.forget_journey!

        support_request.update(**support_request.attributes.symbolize_keys, **@support_form.to_h)
        redirect_to support_request_path(support_request)

      else

        support_request.update(**support_request.attributes.symbolize_keys, **@support_form.to_h)
        redirect_to support_request_path(support_request)

      end

    else

      render :edit
    end
  end

private

  # @return [SupportRequest] restricted to the current user
  #
  def support_request
    @support_request = SupportRequest.where(user_id: current_user.id, id: params[:id]).first
  end

  def form_params
    params.require(:support_form).permit(*%i[
      step phone_number journey_id category_id message_body
    ])
  end
end
