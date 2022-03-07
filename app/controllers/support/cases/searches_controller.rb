# frozen_string_literal: true

module Support
  class Cases::SearchesController < Cases::ApplicationController
    require "will_paginate/array"
    before_action :back_url

    def new
      @form = CaseSearchForm.new
    end

    def create
      @form = CaseSearchForm.from_validation(validation)
      if validation.success?
        # @cases = CaseSearch.find_a_case(@form.search_term).map { |c| CasePresenter.new(c) }.paginate(page: params[:cases_page])
        @cases = Case.last(20).map { |c| CasePresenter.new(c) }.paginate(page: params[:cases_page])
        @filter_form = CaseFilterForm.new
        render :index
      else
        render :new
      end
    end

    def index
      @filter_form = CaseFilterForm.new
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
