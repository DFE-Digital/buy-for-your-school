require "will_paginate/array"

module Support
  class TowersController < ::Support::ApplicationController
    before_action :find_tower
    before_action :redirect_to_case_tab, unless: :turbo_frame_request?, only: :show

    def show
      @filter_form = Support::CaseFilterForm.new(
        **filter_cases_params.to_h.merge(base_cases: @tower.cases, defaults: { state: "live" }),
      )

      @cases = @filter_form.results.paginate(page: params[:page])
    end

  private

    def filter_cases_params
      params.fetch(filter_scope, {}).permit(:category, :agent, :state, :stage, :level, :has_org, :user_submitted, sort: sort_params)
    end

    def filter_scope = "filter_#{@tower.title.parameterize(separator: '_')}_cases"

    def sort_params = %i[ref organisation_name subcategory state agent last_updated action]

    def find_tower
      # filter form still uses id
      @tower = Support::Tower.find_by(title: params[:id]) || Support::Tower.find(params[:id])
    end

    def redirect_to_case_tab
      tower_tab_id = "#{@tower.title.parameterize}-tower"
      redirect_to support_cases_path(anchor: tower_tab_id, tower: { tower_tab_id => { filter_scope => filter_cases_params, page: params.fetch(:page, 1) } })
    end
  end
end
