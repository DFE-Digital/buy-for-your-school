module AllCasesSurvey
  class BaseController < ApplicationController
    skip_before_action :authenticate_user!

    before_action :form
    before_action :back_url

    def edit; end

    def update
      if @form.valid?
        @form.save!
        redirect_to redirect_path
      else
        render :edit
      end
    end

  private

    def form
      @form ||= BaseForm.new(form_params)
    end

    def form_params
      { id: params[:id] }
    end

    def redirect_path; end

    def back_url; end
  end
end
