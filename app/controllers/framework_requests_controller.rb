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
      **framework_request.attributes.symbolize_keys
        .merge(
          school_urn: session[:faf_school] || @framework_request.school_urn,
          group_uid: session[:faf_group] || @framework_request.group_uid,
        ),
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
        group: ActiveModel::Type::Boolean.new.cast(form_params[:group]),
        **validation.to_h.reject { |_k, v| v.blank? },
      )

      # authenticated user / inferred school / message step -> start page
      if @framework_support_form.position?(7) && !current_user.guest? && !current_user.school_urn.nil?
        redirect_to framework_requests_path
      # authenticated user / many schools / school step -> start page
      elsif @framework_support_form.position?(5) && !current_user.guest?
        redirect_to framework_requests_path
      else
        @framework_support_form.back!
        render :new
      end

    elsif validation.success? && validation.to_h[:message_body]

      # capture full "xxxxx - name"
      session[:faf_school] = @framework_support_form.school_urn
      session[:faf_group] = @framework_support_form.group_uid

      # valid form with last question answered
      framework_request = FrameworkRequest.create!(
        user_id: current_user.id,
        **@framework_support_form.to_h.merge(school_urn: urn, group_uid: group_uid),
      )

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

      # capture full "xxxxx - name"
      session[:faf_school] = @framework_support_form.school_urn
      session[:faf_group] = @framework_support_form.group_uid

      # CONDITIONAL extra questions as a result of saved changes

      # if @support_form.step == 3 && !@support_form.has_journey?
      #   @support_form.advance!
      #   render :edit
      # else
      framework_request.update!(**framework_request.attributes.symbolize_keys, **@framework_support_form.to_h.merge(school_urn: urn, group_uid: group_uid))
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
      step back dsi first_name last_name email school_urn group_uid message_body group
    ])
  end

  # @return [FrameworkSupportFormSchema] validated form input
  def validation
    FrameworkSupportFormSchema.new.call(**form_params)
  end

  # @return [UserPresenter] adds form view logic
  def current_user
    @current_user ||= UserPresenter.new(super)
  end

  # @return [FrameworkRequestPresenter]
  def framework_request
    @framework_request = FrameworkRequestPresenter.new(FrameworkRequest.find(params[:id]))
  end

  # FaF specific methods -------------------------------------------------------

  # DSI with inferred school to 7, otherwise 5 to select
  #
  # @return [Integer]
  def initial_position
    if current_user.guest?
      1
    else
      current_user.school_urn ? 7 : 5
    end
  end

  # @return [Hash]
  def conditional_form_params
    if current_user.guest?
      {}
    else
      {
        dsi: true,                            # (step 1)
        group: false,
        first_name: current_user.first_name,  # (step 3)
        last_name: current_user.last_name,    # (step 3)
        email: current_user.email,            # (step 4)
        school_urn: current_user.school_urn,  # (step 5)
        # message (step 6)
      }
    end
  end

  # @return [OrganisationPresenter, nil]
  def organisation
    Support::OrganisationPresenter.new(Support::Organisation.find_by(urn: urn)) if urn
  end

  # Extract the school URN from the format "urn - school name"
  # @example
  #   "100000 - School #1" -> "100000"
  #
  # @return [String, nil]
  def urn
    form_params[:school_urn]&.split(" - ")&.first || @framework_request&.school_urn
  end

  # Extract the group UID from the format "uid - group name"
  # @example
  #   "1000 - Group #1" -> "1000"
  #
  # @return [String, nil]
  def group_uid
    form_params[:group_uid]&.split(" - ")&.first || @framework_request&.group_uid
  end
end
