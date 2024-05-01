module Support
  class Cases::TimelinesController < Cases::ApplicationController
    before_action :back_url

    def create
      timeline = Collaboration::Timeline.create_demo!(case: current_case, start_date: Time.zone.now)
      redirect_to support_case_timeline_path(case_id: current_case, id: timeline.id)
    end

    def show
      @timeline = Collaboration::Timeline.find_by(id: params[:id])
    end

    def edit
      @timeline = Collaboration::Timeline.find_by(id: params[:id])
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
