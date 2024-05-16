require "rails_helper"

describe Collaboration::Publishable do
  subject(:publishable) { Collaboration::Timeline }

  describe "#publish!" do
    let(:support_case) { create(:support_case) }
    let(:timeline_live) { create(:timeline, :published, start_date: Date.parse("2024-05-02"), end_date: Date.parse("2024-05-16"), case: support_case) }
    let(:stage_live) { create(:timeline_stage, :published, complete_by: Date.parse("2024-05-09"), timeline: timeline_live) }
    let!(:task_live_1) { create(:timeline_task, :published, title: "Task 1", start_date: Date.parse("2024-05-02"), end_date: Date.parse("2024-05-03"), stage: stage_live) }
    let!(:task_live_2) { create(:timeline_task, :published, title: "Task 2", start_date: Date.parse("2024-05-07"), end_date: Date.parse("2024-05-09"), stage: stage_live) }
    let(:timeline_draft) { create(:timeline, :draft, start_date: Date.parse("2024-05-02"), end_date: Date.parse("2024-05-16"), case: support_case, live: timeline_live) }
    let(:stage_draft) { create(:timeline_stage, :draft, complete_by: Date.parse("2024-05-16"), timeline: timeline_draft, live: stage_live) }
    let!(:task_draft_1) { create(:timeline_task, :draft, title: "Task 1 NEW", start_date: Date.parse("2024-05-02"), end_date: Date.parse("2024-05-08"), stage: stage_draft, live: task_live_1) }
    let!(:task_draft_2) { create(:timeline_task, :draft, title: "Task 2 NEW", start_date: Date.parse("2024-05-09"), end_date: Date.parse("2024-05-16"), stage: stage_draft, live: task_live_2) }

    context "when publishing a draft" do
      it "does not apply changes to exempt fields - created_at, updated_at, state, and foreign keys" do
        expect { timeline_draft.publish! }.to not_change { timeline_live }
          .and(not_change { stage_live.reload.state })
          .and(not_change { stage_live.reload.created_at })
          .and(not_change { stage_live.reload.timeline_id })
          .and(not_change { stage_live.reload.published_version_id })
          .and(not_change { task_live_1.reload.created_at })
          .and(not_change { task_live_1.reload.state })
          .and(not_change { task_live_1.reload.timeline_stage_id })
          .and(not_change { task_live_1.reload.published_version_id })
          .and(not_change { task_live_2.reload.created_at })
          .and(not_change { task_live_2.reload.state })
          .and(not_change { task_live_2.reload.timeline_stage_id })
          .and(not_change { task_live_2.reload.published_version_id })
        expect(stage_live.reload.updated_at).not_to eq(stage_draft.updated_at)
        expect(task_live_1.reload.updated_at).not_to eq(task_draft_1.updated_at)
        expect(task_live_2.reload.updated_at).not_to eq(task_draft_2.updated_at)
      end

      it "applies relevant draft attributes to the live record" do
        expect { timeline_draft.publish! }.to change { stage_live.reload.complete_by }.from(Time.zone.parse("2024-05-09")).to(Time.zone.parse("2024-05-16"))
          .and(change { task_live_1.reload.title }.from("Task 1").to("Task 1 NEW"))
          .and(change { task_live_1.reload.end_date }.from(Time.zone.parse("2024-05-03")).to(Time.zone.parse("2024-05-08")))
          .and(change { task_live_2.reload.title }.from("Task 2").to("Task 2 NEW"))
          .and(change { task_live_2.reload.start_date }.from(Time.zone.parse("2024-05-07")).to(Time.zone.parse("2024-05-09")))
          .and(change { task_live_2.reload.end_date }.from(Time.zone.parse("2024-05-09")).to(Time.zone.parse("2024-05-16")))
      end

      it "removes draft records" do
        expect { timeline_draft.publish! }.to change(Collaboration::Timeline.draft, :count).from(1).to(0)
          .and(change(Collaboration::TimelineStage.draft, :count).from(1).to(0))
          .and(change(Collaboration::TimelineTask.draft, :count).from(2).to(0))
      end
    end
  end
end
