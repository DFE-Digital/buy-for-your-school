module Bfys
  class SolutionsController < Fabs::ApplicationController
    def index
      @solutions = Solution.all
      render json: @solutions
    end
  end
end
