module Support
  class Cases::Timelines::DraftsController < Cases::ApplicationController
    before_action :draft, except: [:create]
    before_action :timeline, :back_url

    def edit; end

    def create
      @draft = @timeline.draft_version || @timeline.create_draft!
      redirect_to edit_support_case_timeline_draft_path(case_id: current_case, timeline_id: @timeline, id: @draft)
    end

  private

    def draft
      @draft = Collaboration::Timeline.find_by(id: params[:id])
    end

    def timeline
      @timeline = Collaboration::Timeline.find_by(id: params[:timeline_id])
    end

    def back_url
      @back_url = @timeline.published? ? support_case_timeline_path(case_id: current_case, id: @timeline) : support_case_path(current_case)
    end
  end
end
