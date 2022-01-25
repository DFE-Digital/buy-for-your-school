# :nocov:
class FrameworkRequestsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :current_user
  before_action :framework_request, only: %i[edit show update]

  def index
    session[:faf_referer] = request.referer || "none"
  end

  # check answers before submission
  def show
    if framework_request.submitted?
      redirect_to framework_request_submission_path(framework_request)
    end
  end

  def edit
    @framework_support_form = FrameworkSupportForm.new(
      step: params[:step],
      dsi: !current_user.guest?, # ensures a boolean

      **framework_request.attributes.symbolize_keys,
    )
  end

  def new
    @framework_support_form = FrameworkSupportForm.new(
      step: initial_position,
      **conditional_form_params,
    )
  end

  def create
    @framework_support_form = form

    if form_params[:back] == "true"
      revert_form

      render :new
    elsif validation.success? && validation.to_h[:message_body]

      # valid form with last question answered
      framework_request = FrameworkRequest.create!(user_id: current_user.id, **@framework_support_form.to_h)
      redirect_to framework_request_path(framework_request)

    elsif validation.success?
      advance_form

      render :new
    else
      render :new

    end
  end

  def update
    @framework_support_form = form

    if validation.success?

      # if @support_form.step == 3 && @support_form.has_journey?
      #   @support_form.forget_category!
      # elsif @support_form.step == 4 && @support_form.has_category?
      #   @support_form.forget_journey!
      # end

      # if @support_form.step == 3 && !@support_form.has_journey?
      #   @support_form.advance!
      #   render :edit
      # else
      framework_request.update!(**framework_request.attributes.symbolize_keys, **@framework_support_form.to_h)

      redirect_to framework_request_path(framework_request), notice: I18n.t("support_request.flash.updated")
      # end
    else
      render :edit
    end
  end

private

  # @return [FrameworkSupportForm] form object populated with validation messages
  def form
    FrameworkSupportForm.new(
      step: form_params[:step],

      dsi: !current_user.guest?, # ensures a boolean

      messages: validation.errors(full: true).to_h,
      **validation.to_h,
    )
  end

  def form_params
    params.require(:framework_support_form).permit(*%i[
      step back dsi first_name last_name email school_urn message_body
    ])
  end

  # @return [FrameworkSupportFormSchema] validated form input
  def validation
    FrameworkSupportFormSchema.new.call(**form_params)
  end

  # @return [UserPresenter] adds form view logic
  def current_user
    @current_user = UserPresenter.new(super)
  end

  # @return [FrameworkRequestPresenter]
  def framework_request
    @framework_request = FrameworkRequestPresenter.new(FrameworkRequest.find(params[:id]))
  end

  # FaF specific methods -------------------------------------------------------

  # DSI with inferred school to 5, otherwise 4 to select
  #
  # @return [Integer]
  def initial_position
    if current_user.guest?
      1
    else
      current_user.school_urn ? 5 : 4
    end
  end

  # @return [Hash]
  def conditional_form_params
    if current_user.guest?
      {}
    else
      {
        dsi: true,                            # (step 1)
        first_name: current_user.first_name,  # (step 2)
        last_name: current_user.last_name,    # (step 2)
        email: current_user.email,            # (step 3)
        school_urn: current_user.school_urn,  # (step 4)
        # message (step 5)
      }
    end
  end

  # @return [FrameworkSupportForm] form object with updated step number if validation successful
  def advance_form
    if @framework_support_form.step == 2 && current_user.school_urn
      @framework_support_form.advance!(2)
    else
      @framework_support_form.advance!
    end
  end

  # @return [FrameworkSupportForm] form object with reverted step number
  def revert_form
    # binding.pry

    # last step, dsi and inferred school
    if (@framework_support_form.step == 5) && !current_user.guest? && !current_user.school_urn.nil?

      @framework_support_form.back!(4) # go to step 1

    # if @framework_support_form.step == 4 && current_user.school_urn
    #   @framework_support_form.back!(2)
    else
      @framework_support_form.back!
    end
  end
end
# :nocov:
