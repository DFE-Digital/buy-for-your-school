module Energy
  class TasksController < Energy::ApplicationController
    before_action :organisation_details
    def show; end

    def update
      render :show
    end
  end
end
