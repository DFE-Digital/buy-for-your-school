# frozen_string_literal: true

module Support
  class Cases::SearchesController < Cases::ApplicationController
    require "will_paginate/array"
    before_action :back_url

    def index
      @search = Case.ransack(params[:search])
      @result = @search.result.includes(%i[agent category organisation]).all.map { |c| CasePresenter.new(c) }.sort_by(&:last_updated_at_date).paginate(page: params[:page])
    end

    def new
      @search = Case.ransack(params[:search])
      @result = @search.result.includes(%i[agent category organisation]).all.map { |c| CasePresenter.new(c) }.sort_by(&:last_updated_at_date).paginate(page: params[:page])
    end

    private

    def back_url
      @back_url = support_cases_path
    end
  end
end
