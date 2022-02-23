# frozen_string_literal: true
module Support
  class Cases::SearchesController < Cases::ApplicationController
    before_action :back_url

    def new
      @form = CaseSearchForm.new
    end

    def create
      @form = CaseSearchForm.from_validation(validation)
      if validation.success?
        redirect_to support_cases_path(search: @form.ransack_params, anchor: "all-cases")
      else
        render :new
      end
    end

  private

    def back_url
      @back_url = support_cases_path
    end

    def form_params
      params.require(:search_case_form).permit(:search_term).each_value { |value| value.try(:strip!) }
    end

    def validation
      CaseSearchFormSchema.new.call(**form_params)
    end
  end
end
