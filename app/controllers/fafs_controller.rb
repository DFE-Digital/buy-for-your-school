class FafsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :set_back_url
  before_action :support_request, only: %i[show edit update]

  def index
    @source = request.referer
  end

  def show; end

  def new
    @faf_form = FafForm.new(step: 1)
  end

  def create
    @faf_form = form

    if validation.success? && validation.to_h[:message_body]
      support_request = SupportRequest.create!(user_id: current_user.id, **form.to_h)
      redirect_to faf_path(support_request)

    elsif validation.success?

      @faf_form.advance!

      render :new
    else
      render :new
    end
  end

private

  # @return [UserPresenter] adds form view logic
  def current_user
    @current_user = UserPresenter.new(super)
  end

  # @return [SupportRequest] restricted to the current user
  def support_request
    @support_request = SupportRequestPresenter.new(SupportRequest.where(user_id: current_user.id, id: params[:id]).first)
  end

  # @return [FafForm] form object populated with validation messages
  def form
    FafForm.new(step: form_params[:step], messages: validation.errors(full: true).to_h, **validation.to_h)
  end

  def form_params
    params.require(:faf_form).permit(:step, :dsi, :message_body)
  end

  # @return [FafFormSchema] validated form input
  def validation
    FafFormSchema.new.call(**form_params)
  end

  def set_back_url
    @back_url = fafs_path
  end
end
