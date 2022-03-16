# frozen_string_literal: true

module Support
  class Cases::SearchesController < Cases::ApplicationController
    require "will_paginate/array"
    before_action :back_url

    def new
      @form = CaseSearchForm.new
    end

    def index
      @form = CaseSearchForm.from_validation(validation)
      if validation.success?
        @results = SearchCases.results(form_params).map { |c| BasePresenter.new(c) }.paginate(page: params[:cases_page])
        render :index
      else
        render :new
      end
    end

  private

    def back_url
      @back_url = support_cases_path
    end

    def form_params
      params.require(:search_case_form).permit(:search_term, :state, :category, :agent).each_value { |value| value.try(:strip!) }
    end

    def validation
      CaseSearchFormSchema.new.call(**form_params)
    end
  end
end
