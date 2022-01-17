class FafsController < ApplicationController
  skip_before_action :authenticate_user!

  def index; end

  def show; end

  def new
    @faf_form = FafForm.new(step: 1)
  end

  def create
    advance_form
    render :new
  end

private

  # @return [FafForm] form object populated with validation messages
  def form
    FafForm.new(step: form_params[:step], messages: validation.errors(full: true).to_h, **validation.to_h)
  end

  def form_params
    params.require(:faf_form).permit(:step, :dsi, :school_urn)
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
      @faf_form = form
      @faf_form.advance! 2 if validation.success?
    else
      @faf_form = form
      @faf_form.advance! if validation.success?
    end
  end
end
