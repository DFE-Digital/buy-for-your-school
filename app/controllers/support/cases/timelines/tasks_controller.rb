module Support
  class Cases::Timelines::TasksController < Cases::ApplicationController
    before_action :timeline, :task, :back_url

    def edit
      # @files = @timeline.case.fetch_documents
      @files = []
    end

    def update
    end

  private

    def task
      @task = @timeline.tasks.find_by(id: params[:id])
    end

    def timeline
      @timeline = Collaboration::Timeline.find_by(id: params[:timeline_id])
    end

    def back_url
      @back_url = support_case_timeline_path(case_id: current_case, id: @timeline)
    end
  end
end
