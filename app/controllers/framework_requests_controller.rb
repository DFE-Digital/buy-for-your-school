class FrameworkRequestsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :framework_request, only: %i[edit show update]
  before_action :form, only: %i[create update]
  before_action :query_organisation!, only: %i[create update]

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
      **existing_answers.merge(search_results),
    )
  end

  def new
    session.delete(:support_journey)
    clear_search_results!

    @form = FrameworkSupportForm.new(user: current_user)
  end

  def create
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
    if @form.confirmation_required?
      @form.forward
      render :edit

    elsif @form.reselect?
      @form.back!
      render :edit

    elsif validation.success?
      cache_search_results!

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

  # @return [Hash]
  def existing_answers
    framework_request.attributes.symbolize_keys
  end

  # Capture the full search strings "100000 - School #1"
  def cache_search_results!
    session[:faf_school] = @form.school_urn
    session[:faf_group] = @form.group_uid
  end

  # Clear results
  def clear_search_results!
    session.delete(:faf_school)
    session.delete(:faf_group)
  end

  # @see #edit
  # use session stored "URN - NAME" if available
  def orgs
    {
      school_urn: session.fetch(:faf_school, @framework_request&.school_urn),
      group_uid: session.fetch(:faf_group, @framework_request&.group_uid),
    }
  end

  # priority to params then to session vars
  #
  # @return [Hash, nil]
  def existing_orgs
    if params[:group].present?

      find_group = params[:group].eql?("true")

      if find_group
        orgs.merge(school_urn: nil, group: find_group)
      else
        orgs.merge(group_uid: nil, group: find_group)
      end

    elsif session[:faf_group].present?

      orgs.merge(group: session[:faf_group].present?)
    end
  end

  # @see form
  #
  # Repopulate form fields based on previous searches, used when stepping back
  #
  # @return [Hash]
  def search_results
    existing_orgs || orgs
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
