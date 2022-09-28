class FrameworkRequestsController < ApplicationController
  skip_before_action :authenticate_user!

  before_action :form, only: %i[create update]
  before_action :query_organisation!, only: %i[create update]
  before_action :framework_request, only: %i[edit show update]
  before_action :cached_orgs, except: :index

  def index
    session[:support_journey] = "faf"
    session[:faf_referrer] = referral_link
  end

  def show
    @current_user = UserPresenter.new(current_user)

    if framework_request.submitted?
      redirect_to framework_request_submission_path(framework_request)
    end
  end

  def edit
    @form =
      FrameworkSupportForm.new(
        user: current_user,
        dsi: !current_user.guest?,
        **persisted_data,
        **cached_search_result,
      )
  end

  def new
    session.delete(:faf_group)
    session.delete(:faf_school)

    @form = FrameworkSupportForm.new(user: current_user)
  end

  def create
    session.delete(:support_journey) unless current_user.guest?

    if @form.restart? && back_link?
      redirect_to framework_requests_path
    elsif validation.success? && validation.to_h[:special_requirements]
      request = FrameworkRequest.create!(@form.data)
      redirect_to framework_request_path(request)
    else
      if back_link?
        @form.backward
      elsif @form.reselect?
        @form.back!
      elsif validation.success?
        cache_search_result!
        @form.forward
      end
      render :new
    end
  end

  def update
    if @form.next?
      @form.forward
      render :edit
    elsif @form.reselect?
      @form.back!
      render :edit
    elsif validation.success?
      cache_search_result!
      framework_request.update!(**persisted_data, **@form.data)
      redirect_to framework_request_path(framework_request), notice: I18n.t("support_request.flash.updated")
    else
      render :edit
    end
  end

private

  def referral_link
    params[:referred_by] ? Base64.decode64(params[:referred_by]) : request.referer || "direct"
  end

  # @return [FrameworkSupportForm] form object populated with validation messages
  def form
    @form =
      FrameworkSupportForm.new(
        user: current_user,
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
      org_id
      org_confirm
      first_name
      last_name
      email
      message_body
      procurement_amount
      confidence_level
      special_requirements_choice
      special_requirements
    ])
  end

  # @return [FrameworkSupportFormSchema] validated form input
  def validation
    @validation ||= FrameworkSupportFormSchema.new.call(**form_params)
  end

  # @return [FrameworkRequestPresenter]
  def framework_request
    @framework_request = FrameworkRequestPresenter.new(FrameworkRequest.find(params[:id]))
  end

  # @return [Hash]
  def persisted_data
    framework_request.attributes.symbolize_keys
  end

  # TODO: maybe? - move the form back param into the parent class
  #
  # @return [Boolean]
  def back_link?
    @back_link = form_params[:back].eql?("true")
  end

  # Save guest's autocompleted search result once confirmed
  #
  # @return [nil]
  def cache_search_result!
    return unless current_user.guest? && @form.position?(4)

    if @form.group
      session[:faf_group] = @form.org_id
      session.delete(:faf_school)
    else
      session[:faf_school] = @form.org_id
      session.delete(:faf_group)
    end
  end

  # Additional params on "Can't find it" and "Change" links
  #
  # @return [Hash] { step: "2", org_id: "XXX - School", group: "false" }
  def cached_search_result
    return { step: params[:step] } unless current_user.guest?

    case params[:group]
    when "true"
      { step: params[:step], group: params[:group], org_id: session[:faf_group] }
    when "false"
      { step: params[:step], group: params[:group], org_id: session[:faf_school] }
    else
      { step: params[:step] }
    end
  end

  # Debugging in view
  def cached_orgs
    @cached_group = session[:faf_group]
    @cached_school = session[:faf_school]
  end

  def query_organisation!
    # TODO: refactor to return a single struct capable of providing all data needed
    #       refer to the Guest struct implementation
    #
    # @example
    #   {
    #     group: [Boolean],
    #     org_id: [String],
    #     name: [String],
    #     address: [String],
    #     ...
    #   }
    #
    # @return [Hash]
    #
    # QueryOrganisation.call(@form.found_uid_or_urn)

    if @form.group
      group = Support::EstablishmentGroup.find_by(uid: @form.found_uid_or_urn)
      @group = Support::EstablishmentGroupPresenter.new(group) if group
    else
      school = Support::Organisation.find_by(urn: @form.found_uid_or_urn)
      @school = Support::OrganisationPresenter.new(school) if school
    end
  end
end
