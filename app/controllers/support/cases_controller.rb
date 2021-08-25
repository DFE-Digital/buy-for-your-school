# TODO: remove :nocov: and start testing
# :nocov:
module Support
  class CasesController < ApplicationController
    def index
      @cases = Support::Case.all.map { |c| CasePresenter.new(c) }
    end

    def show
      c = Support::Case.find_by(id: sanitised_id)

      @case = CasePresenter.new(c)
    end

    private
    
    def sanitised_id
      params[:id].to_s.delete('^0-9')
    end
  end
end
# :nocov: