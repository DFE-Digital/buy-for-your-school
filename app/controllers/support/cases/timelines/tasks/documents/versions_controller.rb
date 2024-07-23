module Support
  class Cases::Timelines::Tasks::Documents::VersionsController < Cases::ApplicationController
    before_action :timeline, :task, :document
    before_action :back_url, only: %i[show]

    def show
      @versions = @document.version_history
    end

  private

    def document
      @document = @task.documents.find_by(id: params[:document_id])
    end

    def task
      @task = @timeline.tasks.find_by(id: params[:task_id])
    end

    def timeline
      @timeline = Collaboration::Timeline.find_by(id: params[:timeline_id])
    end

    def back_url
      @back_url = support_case_timeline_task_what_to_do_path(case_id: current_case, timeline_id: @timeline, task_id: @task)
    end
  end
end
