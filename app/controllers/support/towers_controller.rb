require "will_paginate/array"

module Support
  class TowersController < ::Support::ApplicationController
    def show
      @back_url = request.referer || support_cases_path

      @towers = Support::Tower.every_tower

      @tower = tower

      @filter_form = Support::CaseFilterForm.new(
        **filter_cases_params.to_h.merge(base_cases: @tower.cases),
      )

      @cases = @filter_form.results.paginate(page: params[:page], per_page: 30)
    end

  private

    def tower
      params[:id] == "no-tower" ? Support::Tower.nil_tower : Support::Tower.find(params[:id])
    end

    def filter_cases_params
      params.fetch(:filter_cases, {}).permit(:category, :agent, :state)
    end
  end
end
