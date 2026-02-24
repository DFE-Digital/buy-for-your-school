module Bfys
  class SolutionsController < Fabs::ApplicationController
    skip_before_action :check_fabs_flag
    def index
      @solutions = Solution.all
      render json: @solutions
    end
  end
end
