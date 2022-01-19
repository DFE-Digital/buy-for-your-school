class FafsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :faf, only: %i[show]
  before_action :faf_form, only: %i[create]
  before_action :faf_presenter, only: %i[show]
  before_action :set_back_url, only: %i[create new]

  def index; end

  # check answers before submission
  def show
    if @faf.submitted?
      # TODO: redirect to faf_submissions_controller
    end
  end

  def new
    step = params[:step] || 1
    @faf_form = FafForm.new(step: step)
    session[:faf] = true
  end

  def create
    @faf_form.advance! if validation.success?
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
    params.require(:faf_form).permit(:step, :dsi)
  end

  # @return [FafFormSchema] validated form input
  def validation
    FafFormSchema.new.call(**form_params)
  end

  def faf_presenter
    @faf_presenter = FafPresenter.new(@faf)
  end

  # @return [FrameworkRequest]
  def faf
    @faf = FrameworkRequest.find(params[:id])
  end

  def current_user
    @current_user = UserPresenter.new(super)
  end

  def set_back_url
    @back_url = fafs_path
  end
end
