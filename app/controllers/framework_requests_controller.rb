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
    query_organisation! # TODO: this method sets instance variables by accessing data in Case Management

    @form.forget_org

    if back_link? || @form.affiliation_request_unconfirmed?

      if @form.restart?
        redirect_to framework_requests_path
      else
        @form.backward
        render :new
      end

    # validated and complete
    elsif validation.success? && validation.to_h[:message_body]
      store_org_ids
      request = FrameworkRequest.create!(@form.data)
      redirect_to framework_request_path(request)

    # validated but incomplete
    elsif validation.success?
      @form.forward
      render :new
    else
      render :new
    end
  end

  def update
    if validation.success?
      @form.forget_org

      store_org_ids

      # Select school/group if choice changed
      if @form.position?(2)
        @form.go_to!(3)
        render :edit
      else
        existing_answers = framework_request.attributes.symbolize_keys
        framework_request.update!(**existing_answers, **@form.data)

        redirect_to framework_request_path(framework_request), notice: I18n.t("support_request.flash.updated")
      end
    else
      render :edit
    end
  end

private

  # @return [FrameworkSupportForm] form object populated with validation messages
  def form
    @form ||= FrameworkSupportForm.new(
      user: current_user,
      dsi: !current_user.guest?,
      step: form_params[:step],
      messages: validation.errors(full: true).to_h,
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

  # Capture the full search strings for use when editing
  def store_org_ids
    session[:faf_school] = @form.school_urn
    session[:faf_group] = @form.group_uid
  end

  # @return [Hash] recover JS search result strings from session
  def search_results
    {
      school_urn: session.fetch(:faf_school, @framework_request.school_urn),
      group_uid: session.fetch(:faf_group, @framework_request.group_uid),
    }
  end

  # TODO: move the form back param into the parent class maybe?
  # @return [Boolean]
  def back_link?
    form_params[:back] == "true"
  end

  # TODO: refactor to return a single hash capable of providing all data needed
  #
  # @example
  #
  #   {
  #     type: "group/school",
  #     identifier: "1234",
  #     name: "Group or School Name",
  #   }
  #
  # @return [Hash]
  def query_organisation!
    # QueryOrganisation.call(@form&.urn || @form&.uid)
    @organisation = Support::OrganisationPresenter.new(Support::Organisation.find_by(urn: @form.urn)) if @form&.urn
    @establishment_group = Support::EstablishmentGroupPresenter.new(Support::EstablishmentGroup.find_by(uid: @form.uid)) if @form&.uid
  end
end
