# frozen_string_literal: true

module Support
  class Cases::SearchesController < Cases::ApplicationController
    require "will_paginate/array"

    def new
      @form = CaseSearchForm.new
      @back_url = support_cases_path
    end

    def index
      @form = CaseSearchForm.from_validation(validation)
      if validation.success?
        @results = SearchCases.results(form_params).map { |c| CasePresenter.new(c) }.paginate(page: params[:my_cases_page])
        @back_url = new_support_case_search_path
        render :index
      else
        @back_url = support_cases_path
        render :new
      end
    end

  private

    def form_params
      params.require(:search_case_form).permit(:search_term, :state, :category, :agent).each_value { |value| value.try(:strip!) }
    end

    def validation
      CaseSearchFormSchema.new.call(**form_params)
    end
  end
end
