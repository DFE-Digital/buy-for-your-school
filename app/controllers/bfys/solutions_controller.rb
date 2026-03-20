module Bfys
  class SolutionsController < Fabs::ApplicationController
    skip_before_action :verify_authenticity_token

    def index
      @solutions = Solution.all
      render json: @solutions
    end
  end
end
