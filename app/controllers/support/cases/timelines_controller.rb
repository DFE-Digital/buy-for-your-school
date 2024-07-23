module Support
  class Cases::TimelinesController < Cases::ApplicationController
    before_action :back_url

    def create
      timeline = Collaboration::Timeline.create_default!(case: current_case, start_date: Time.zone.now)
      current_case.initialise_default_documents!
      redirect_to edit_support_case_timeline_draft_path(case_id: current_case, timeline_id: timeline, id: timeline)
    end

    def show
      @timeline = Collaboration::Timeline.find_by(id: params[:id])
    end

    def edit
      @timeline = Collaboration::Timeline.find_by(id: params[:id])
      # @draft_timeline = @timeline.draft_version
      @back_url = support_case_timeline_path(case_id: current_case, id: @timeline.id)
    end

    def versions
      @timeline = Collaboration::Timeline.find_by(id: params[:timeline_id])
      @versions = @timeline.versions
      @back_url = support_case_timeline_path(case_id: current_case.id, id: @timeline.id)
    end

  private

    def back_url
      @back_url = support_case_path(@current_case)
    end
  end
end
