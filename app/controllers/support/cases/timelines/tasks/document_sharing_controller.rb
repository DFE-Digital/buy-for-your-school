module Support
  class Cases::Timelines::Tasks::DocumentSharingController < Cases::ApplicationController
    before_action :timeline, :task

    def create
      @current_case.invite_contact_to_sharepoint unless @current_case.contact_invited_to_sharepoint
      statuses = []
      @task.documents.each do |doc|
        res = doc.invite_contact_to_collaborate
        statuses << res
        doc.update!(permissions: :read_write, url: doc.fetch_url)
      end

      redirect_to support_case_timeline_task_what_to_do_path(case_id: @current_case, timeline_id: @timeline, task_id: @task), notice: "Case contact invited"
    end

  private

    def task
      @task = @timeline.tasks.find_by(id: params[:task_id])
    end

    def timeline
      @timeline = Collaboration::Timeline.find_by(id: params[:timeline_id])
    end
  end
end
