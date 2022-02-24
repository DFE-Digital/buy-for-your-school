class FrameworkRequestsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :framework_request, only: %i[edit show update]
  before_action :form, only: %i[create update]

  def index
    session[:support_journey] = "faf"
    session[:faf_referer] = request.referer || "direct"
  end

  def show
    @current_user = UserPresenter.new(current_user)

    if framework_request.submitted?
      redirect_to framework_request_submission_path(framework_request)
    end
  end

  def edit
    @form = FrameworkSupportForm.new(
      user: current_user,
      dsi: !current_user.guest?,
      step: params[:step],
      **framework_request.attributes.symbolize_keys.merge(search_results),
    )
  end

  def new
    session.delete(:support_journey)
    @form = FrameworkSupportForm.new(user: current_user)
  end

  def create
    query_organisation!

    if @form.restart? && back_link?
      redirect_to framework_requests_path
    elsif validation.success? && validation.to_h[:message_body]
      request = FrameworkRequest.create!(@form.data)
      redirect_to framework_request_path(request)
    else

      if back_link?
        @form.backward
      elsif @form.reselect?
        @form.back!
      elsif validation.success?
        @form.forward
        cache_search_results!
      end

      render :new
    end
  end

  def update
    query_organisation!

    if @form.confirmation_required?
      @form.forward
      render :edit

    elsif @form.reselect?
      @form.back!
      render :edit

    elsif validation.success?
      cache_search_results!

      existing_answers = framework_request.attributes.symbolize_keys
      framework_request.update!(**existing_answers, **@form.data)

      redirect_to framework_request_path(framework_request), notice: I18n.t("support_request.flash.updated")
    else
      render :edit
    end
  end

private

  # @return [FrameworkSupportForm] form object populated with validation messages
  def form
    @form =
      FrameworkSupportForm.new(
        user: current_user,
        dsi: !current_user.guest?,
        step: form_params[:step],
        messages: validation.errors(full: true).to_h,
        **search_results,
        **validation.to_h,
      )
  end

  def form_params
    params.require(:framework_support_form).permit(*%i[
      step
      back
      dsi
      group
      first_name
      last_name
      email
      school_urn
      group_uid
      correct_organisation
      correct_group
      message_body
    ])
  end

  # @return [FrameworkSupportFormSchema] validated form input
  def validation
    FrameworkSupportFormSchema.new.call(**form_params)
  end

  # @return [FrameworkRequestPresenter]
  def framework_request
    @framework_request = FrameworkRequestPresenter.new(FrameworkRequest.find(params[:id]))
  end

  # Cleared once submitted
  #
  # @see FrameworkRequestSubmissionsController#update
  #
  # Capture the full search strings for use when editing
  def cache_search_results!
    session[:faf_school] = @form.school_urn
    session[:faf_group] = @form.group_uid
  end

  # @return [Hash] recover JS search result strings from session
  def search_results
    {
      school_urn: session.fetch(:faf_school, @framework_request&.school_urn),
      group_uid: session.fetch(:faf_group, @framework_request&.group_uid),
    }
  end

  # TODO: move the form back param into the parent class maybe?
  #
  # @return [Boolean]
  def back_link?
    @back_link = form_params[:back].eql?("true")
  end

  # TODO: refactor to return a single hash capable of providing all data needed
  #
  # @example
  #   {
  #     type: "group/school",
  #     identifier: "1234",
  #     name: "Group or School Name",
  #   }
  #
  # @return [Hash]
  def query_organisation!
    # QueryOrganisation.call(@form&.urn || @form&.uid)

    organisation = Support::Organisation.find_by(urn: @form.urn)
    @organisation = Support::OrganisationPresenter.new(organisation) if organisation

    establishment_group = Support::EstablishmentGroup.find_by(uid: @form.uid)
    @establishment_group = Support::EstablishmentGroupPresenter.new(establishment_group) if establishment_group
  end
end
