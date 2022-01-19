class FafsController < ApplicationController
  skip_before_action :authenticate_user!
  # before_action :support_request, only: %i[show]
  before_action :faf, only: %i[show]
  before_action :faf_form, only: %i[create]
  before_action :faf_presenter, only: %i[show]

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
    if validation.success? && validation.to_h[:message_body]
      # TODO: to be updated to use FrameworkRequest when in place
      faf = FrameworkRequest.create!(user_id: current_user&.id, **form.to_h)
      redirect_to faf_path(faf)

    elsif validation.success?

      @faf_form.advance!

      render :new
    else
      render :new
    end
  end

private

  # @return [UserPresenter] adds form view logic
  # def current_user
  #   @current_user = UserPresenter.new(super)
  # end

  # @return [FafForm] form object populated with validation messages
  def faf_form
    @faf_form = FafForm.new(
      step: form_params[:step],
      messages: validation.errors(full: true).to_h,
      **validation.to_h,
    )
  end

  def form_params
    params.require(:faf_form).permit(:step, :dsi, :message_body)
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
end
