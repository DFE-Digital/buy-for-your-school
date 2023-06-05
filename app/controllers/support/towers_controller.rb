require "will_paginate/array"

module Support
  class TowersController < ::Support::ApplicationController
    before_action :find_tower
    before_action :redirect_to_case_tab, unless: :turbo_frame_request?, only: :show

    include Support::Concerns::FilterParameters

    def show
      @filter_form = Support::CaseFilterForm.new(
        **filter_params_for(filter_scope).to_h.merge(base_cases: @tower.cases, defaults: { state: "live" }),
      )

      @cases = @filter_form.results.paginate(page: params[:page])
    end

  private

    def filter_scope = "filter_#{@tower.title.parameterize(separator: '_')}_cases"

    def find_tower
      # filter form still uses id
      @tower = Support::Tower.find_by(title: params[:id]) || Support::Tower.find(params[:id])
    end

    def redirect_to_case_tab
      tower_tab_id = "#{@tower.title.parameterize}-tower"
      redirect_to support_cases_path(anchor: tower_tab_id, tower: { tower_tab_id => { filter_scope => filter_params_for(filter_scope), page: params.fetch(:page, 1) } })
    end
  end
end
