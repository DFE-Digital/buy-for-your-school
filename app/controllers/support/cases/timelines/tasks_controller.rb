module Support
  class Cases::Timelines::TasksController < Cases::ApplicationController
    include HasDateParams

    before_action :timeline, :back_url

    def new
      @stage = Collaboration::TimelineStage.find(params[:stage])
      @creator = Collaboration::TimelineTask::Creator.new(start_date: 1.business_day.after(@stage.tasks.last.end_date))
    end

    def create
      # byebug
      @creator = Collaboration::TimelineTask::Creator.new(creator_params.merge(timeline:).merge(stage: Collaboration::TimelineStage.find(creator_params[:stage])))
      if @creator.valid?
        @creator.save!
        redirect_to edit_support_case_timeline_path(case_id: current_case, id: timeline.id)
      else
        render :edit
      end
    end

    def edit
      @task = Collaboration::TimelineTask.find_by(id: params[:id])
      @editor = @task.editor
    end

    def update
      @task = Collaboration::TimelineTask.find_by(id: params[:id])
      # byebug
      @editor = @task.editor(editor_params)

      if @editor.valid?
        @editor.save!
        redirect_to edit_support_case_timeline_path(case_id: current_case, id: timeline.id)
      else
        render :edit
      end
    end

  private

    def creator_params
      form_params(:support_timeline_task_creator)
          .except("start_date(3i)", "start_date(2i)", "start_date(1i)", "end_date(3i)", "end_date(2i)", "end_date(1i)")
          .merge(start_date: date_param(:support_timeline_task_creator, :start_date).compact_blank)
          .merge(end_date: date_param(:support_timeline_task_creator, :end_date).compact_blank)
          .compact_blank
    end

    def editor_params
      form_params(:support_timeline_task_editor)
          .except("start_date(3i)", "start_date(2i)", "start_date(1i)", "end_date(3i)", "end_date(2i)", "end_date(1i)")
          .merge(start_date: date_param(:support_timeline_task_editor, :start_date).compact_blank)
          .merge(end_date: date_param(:support_timeline_task_editor, :end_date).compact_blank)
          .compact_blank
    end

    def form_params(scope)
      params.require(scope).permit(:title, :timeframe_type, :start_date, :end_date, :duration, :stage)
    end

    def timeline
      @timeline = Collaboration::Timeline.find_by(id: params[:timeline_id])
    end

    def back_url
      @back_url = support_case_timeline_path(case_id: current_case.id, id: @timeline.id)
    end
  end
end
