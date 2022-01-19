class FafsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :faf, only: %i[show]
  before_action :faf_form, only: %i[create]
  before_action :faf_presenter, only: %i[show]

  def index; end

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
    else
      advance_form
    end

    render :new
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

  def form_params
    params.require(:faf_form).permit(:step, :dsi, :school_urn, :back)
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
    if form_params[:step].to_i == 2 && current_user.supported_schools.count == 1
      form_params[:school_urn] = current_user.supported_schools.first[:urn]
      @faf_form.advance! 2 if validation.success?
    else
      @faf_form.advance! if validation.success?
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
