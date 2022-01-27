class FrameworkRequestsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :current_user
  before_action :framework_request, only: %i[edit show update]

  def index
    session[:faf_referer] = request.referer || "direct"
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
    @organisation = organisation

    # DSI users clicking back on the FaF support form skip steps intended for guests
    if form_params[:back] == "true"

      # forget validation errors when stepping back
      @framework_support_form = FrameworkSupportForm.new(
        step: form_params[:step],
        dsi: !current_user.guest?,
        **validation.to_h.reject { |_k, v| v.blank? },
      )

      # authenticated user / inferred school / message step -> start page
      if @framework_support_form.position?(6) && !current_user.guest? && !current_user.school_urn.nil?
        redirect_to framework_requests_path
      # authenticated user / many schools / school step -> start page
      elsif @framework_support_form.position?(4) && !current_user.guest?
        redirect_to framework_requests_path
      else
        @framework_support_form.back!
        render :new
      end

    elsif validation.success? && validation.to_h[:message_body]

      # valid form with last question answered
      framework_request = FrameworkRequest.create!(user_id: current_user.id, **@framework_support_form.to_h)
      redirect_to framework_request_path(framework_request)

    elsif validation.success?

      @framework_support_form.advance!

      render :new
    else
      render :new

    end
  end

  def update
    @framework_support_form = form

    if validation.success?

      # CONDITIONAL extra questions as a result of saved changes

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
      dsi: !current_user.guest?,
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
      current_user.school_urn ? 6 : 4
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
        # message (step 6)
      }
    end
  end

  # @return [OrganisationPresenter, nil]
  def organisation
    urn = form_params[:school_urn]
    Support::OrganisationPresenter.new(Support::Organisation.find_by(urn: urn.split(" - ").first)) if urn
  end
end
