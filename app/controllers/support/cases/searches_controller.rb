# frozen_string_literal: true

module Support
  class Cases::SearchesController < Cases::ApplicationController
    require "will_paginate/array"

    include Support::Concerns::FilterParameters

    def new
      @form = cec_namespace? ? Support::Case.dfe_energy.filtering : Support::Case.filtering
      @back_url = cec_namespace? ? cec_onboarding_cases_path : support_cases_path
    end

    def index
      @form = cec_namespace? ? Support::Case.dfe_energy.filtering(filter_params_for(:search_case_form)) : Support::Case.filtering(filter_params_for(:search_case_form))

      if @form.valid?(:searching)
        @results = @form.results.map { |c| CasePresenter.new(c) }.paginate(page: params[:my_cases_page])
        @back_url = url_from(back_link_param) || portal_new_case_search_path
        render :index
      else
        @back_url = cec_namespace? ? cec_onboarding_cases_path : support_cases_path
        render :new
      end
    end

    def cec_namespace?
      (current_agent.roles & %w[cec cec_admin]).any?
    end

    def portal_namespace
      (current_agent.roles & %w[cec cec_admin]).any? ? "cec" : "support"
    end

    helper_method def portal_case_search_index_path
      send("#{portal_namespace}_case_search_index_path")
    end

    helper_method def portal_new_case_search_path
      if cec_namespace?
        send("cec_case_search_new_path")
      else
        send("new_support_case_search_path")
      end
    end

    helper_method def portal_case_path(case_id, additional_params = {})
      if cec_namespace?
        send("cec_onboarding_case_path", case_id, additional_params)
      else
        send("support_case_path", case_id, additional_params)
      end
    end
  end
end
