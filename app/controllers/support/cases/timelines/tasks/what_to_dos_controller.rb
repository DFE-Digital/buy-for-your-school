module Support
  class Cases::Timelines::Tasks::WhatToDosController < Cases::ApplicationController
    before_action :timeline, :task
    before_action :back_url, only: %i[edit update]

    def edit
      @file_picker = @task.file_picker(document_source:)
    end

    def update
      @file_picker = @task.file_picker(document_source:)
      @file_picker.pick_documents(file_picker_params[:documents])
      if @file_picker.valid?
        @file_picker.save!
        redirect_to @back_url
      else
        render :edit
      end
    end

  private

    def document_source
      @document_source ||= @timeline.case.fetch_documents_for_stage(@task.stage.stage)
    end

    def file_picker_params
      params.require(:file_picker).permit(documents: [])
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
