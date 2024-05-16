module Support
  class Cases::Timelines::Drafts::PublishController < Cases::ApplicationController
    before_action :draft, :timeline, :back_url

    def show
      @proposed_changes = @timeline.proposed_changes
    end

    def create
      @draft.publish!
      redirect_to support_case_timeline_path(case_id: current_case, id: @timeline), notice: "Timeline published"
    end

  private

    def draft
      @draft = Collaboration::Timeline.find_by(id: params[:draft_id])
    end

    def timeline
      @timeline = Collaboration::Timeline.find_by(id: params[:timeline_id])
    end

    def back_url
      @back_url = edit_support_case_timeline_draft_path(case_id: current_case, timeline_id: @timeline, id: @draft)
    end
  end
end
