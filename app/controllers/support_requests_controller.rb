# frozen_string_literal: true

class SupportRequestsController < ApplicationController
  before_action :set_support_request, only: %i[show edit update]

  # start the process
  def index; end

  # check your answers before submission
  def show; end

  # first question
  def new
    # binding.pry
    # @support_form = SupportForm::Step1.new
      # @support_form = SupportForm::Step1.new(step: 1)
    # @support_form = SupportForm.new(step: 1)
    # @support_form = form_class.new
    @support_form = SupportForm.build
  end


  # questions 2 onwards until complete
  def create
    @categories = Category.all



    # form_class = "SupportForm::Step#{form_params[:step]}".constantize
    # @support_form = form_class.new(**form_params)

    @support_form = SupportForm.build(form_params[:step], form_params)



    # return to edit if validation fails
    if @support_form.invalid?
      render :new

    else
      # binding.pry
      # save if the last
      if @support_form.last_step?
        @support_form.support_request.save!

        redirect_to support_request_path(@support_form.support_request),
                    notice: I18n.t("support_requests.flash.created")

      # increment if not last
      else
        @support_form.increment!
        render :new
      end
    end



    # if @support_form.save
    #   if @support_form.last_step?
    #     redirect_to support_request_path(@support_form.support_request),
    #                 notice: I18n.t("support_requests.flash.created")
    #   else
    #     render :new
    #   end
    # else
    #   render :new
    # end
  end






  def edit
    form_class = "SupportForm::Step#{params[:step]}".constantize
    @support_form = form_class.new(step: params[:step],
    # @support_form = SupportForm.build(params[:step],
                                   journey_id: @support_request.journey_id,
                                   category_id: @support_request.category_id,
                                   phone_number: @support_request.phone_number,
                                   message: @support_request.message)
  end

  def update
    @support_form = SupportForm.build(form_params[:step], form_params)

    if @support_form.valid? && @support_request.update(form_params.except(:step))

      redirect_to support_request_path(@support_request),
                  notice: I18n.t("support_requests.flash.updated")
    else
      render :edit
    end


    # if @support_request.update(form_params.except(:step))

    #   redirect_to support_request_path(@support_request),
    #               notice: I18n.t("support_requests.flash.updated")
    # else
    #   render :edit
    # end
  end

private

  # def form_class
  #   "SupportForm::Step#{params[:step]}".constantize
  # end

  # @return [SupportRequest] restricted to the current user
  #
  def set_support_request
    @support_request = SupportRequest.where(user_id: current_user.id, id: params[:id]).first
  end

  # @return [ActionController::Parameters] validate request attribute names from form
  #
  def form_params
    # params.require(:support_form).permit(*SupportForm.new.attributes).merge(user: current_user)
    params.require(:support_form).permit(*SupportForm.new.attributes)
  end
end
