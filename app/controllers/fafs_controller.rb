class FafsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :faf, only: %i[show]
  before_action :faf_form, only: %i[create]
  before_action :faf_presenter, only: %i[show create]

  def index
    @source = request.referer
  end

  # check answers before submission
  def show
    if @faf.submitted?
      # TODO: redirect to faf_submissions_controller
    end
  end

  def new
    @faf_form = FafForm.new(step: 1)
  end

  def create
    if form_params[:back] == "true"
      revert_form
    elsif validation.success? && validation.to_h[:message_body]
      faf = FrameworkRequest.create!(user_id: user_id, **faf_form.to_h)
      redirect_to faf_path(faf)
    elsif validation.success?
      @faf_form.advance!
      render :new
    else
      render :new
    end
  end

private

  # @return [FafForm] form object populated with validation messages
  def faf_form
    @faf_form = FafForm.new(
      step: form_params[:step],
      messages: validation.errors(full: true).to_h,
      **validation.to_h,
    )
  end

  # Only return current user id if user session exists and user has selected
  # to use DSI for request
  #
  # @return [String]
  def user_id
    return unless params[:dsi].in?(["true", true])
    return if current_user.guest?

    current_user.id
  end

  def form_params
    add_school_urn_to_params if params[:step] == 2 && current_user.supported_schools.one?

    params.require(:faf_form).permit(:step, :dsi, :school_urn, :message_body, :back)
  end

  def add_school_urn_to_params
    school_urn = current_user.supported_schools.first[:urn].to_s

    params[:faf_form].merge!(school_urn: school_urn)
  end

  # @return [FafFormSchema] validated form input
  def validation
    FafFormSchema.new.call(**form_params)
  end

  # @return [UserPresenter] adds form view logic
  def current_user
    @current_user = UserPresenter.new(super)
  end

  # @return [FafForm] form object with updated step number if validation successful
  def advance_form
    if form_params[:step].to_i == 2 && current_user.supported_schools.one?
      @faf_form.advance! 2
    else
      @faf_form.advance!
    end
  end

  # @return [FafForm] form object with reverted step number
  def revert_form
    if form_params[:step].to_i == 4 && current_user.supported_schools.count == 1
      @faf_form.back! 2
    else
      @faf_form.back!
    end
  end

  def faf_presenter
    @faf_presenter = FafPresenter.new(@faf)
  end

  # @return [FrameworkRequest]
  def faf
    @faf = FrameworkRequest.find(params[:id])
  end
end
