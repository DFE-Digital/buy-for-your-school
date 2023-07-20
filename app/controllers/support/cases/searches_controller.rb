# frozen_string_literal: true

module Support
  class Cases::SearchesController < Cases::ApplicationController
    require "will_paginate/array"

    include Support::Concerns::FilterParameters

    def new
      @form = Support::Case::Filtering.new
      @back_url = support_cases_path
    end

    def index
      @form = Support::Case::Filtering.new(filter_params_for(:search_case_form))

      if @form.valid?(:searching)
        @results = Support::Case.search(@form).map { |c| CasePresenter.new(c) }.paginate(page: params[:my_cases_page])
        @back_url = new_support_case_search_path
        render :index
      else
        @back_url = support_cases_path
        render :new
      end
    end
  end
end
