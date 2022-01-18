class FafsController < ApplicationController
  skip_before_action :authenticate_user!

  def index; end

  def show; end

  def new
    step = params[:step] || 1
    @faf_form = FafForm.new(step: step)
    session[:faf] = true
  end

  def create
    @faf_form = form
    @faf_form.advance! if validation.success?
    render :new
  end

private

  # @return [FafForm] form object populated with validation messages
  def form
    FafForm.new(step: form_params[:step], messages: validation.errors(full: true).to_h, **validation.to_h)
  end

  def form_params
    params.require(:faf_form).permit(:step, :dsi)
  end

  # @return [FafFormSchema] validated form input
  def validation
    FafFormSchema.new.call(**form_params)
  end

  def current_user
    @current_user = UserPresenter.new(super)
  end
end
