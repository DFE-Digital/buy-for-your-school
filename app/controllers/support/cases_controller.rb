module Support
  class CasesController < ApplicationController
    def index
      @cases = Support::Case.all.map { |c| CasePresenter.new(c) }
    end

    def show
      c = Support::Case.find_by(id: params[:id])

      @case = CasePresenter.new(c)
    end
  end
end
