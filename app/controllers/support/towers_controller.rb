require "will_paginate/array"

module Support
  class TowersController < ::Support::ApplicationController
    def show
      @tower = Support::Tower.find(params[:id])

      @filter_form = Support::CaseFilterForm.new(
        **filter_cases_params.to_h.merge(base_cases: @tower.cases),
      )
      @cases = @filter_form.results.paginate(page: params[:page], per_page: 30)
    end

  private

    def filter_cases_params
      params.fetch(:filter_cases, {}).permit(:category, :agent, :state)
    end
  end
end
