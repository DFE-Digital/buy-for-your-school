RSpec.feature "Case worker can open a case" do
  include_context "with an agent"

  before do
    visit support_case_path(support_case)
    click_link "Reopen case"
  end

  context "when re-opening a case" do
    let(:support_case) { create(:support_case, :resolved) }
    let(:activity_log_item) { Support::ActivityLogItem.last }

    it "redirects to the case" do
      expect(page).to have_current_path(support_case_path(support_case), ignore_query: true)
    end

    it "changes status of case to opened" do
      support_case.reload
      expect(support_case.state).to eq "opened"
    end

    it "records the case being reopened" do
      expect(activity_log_item.support_case_id).to eq support_case.id
      expect(activity_log_item.action).to eq "change_state"
      expect(activity_log_item.data).to eq({ "old_state" => "resolved", "new_state" => "opened" })
    end

    it "records the interaction for case history" do
      expect(Support::Interaction.last.body).to eql "From resolved to open by Procurement Specialist on #{Time.zone.now.to_formatted_s(:short)}"
    end
  end

  context "when a case is on hold" do
    let(:support_case) { create(:support_case, :on_hold) }
    let(:activity_log_item) { Support::ActivityLogItem.last }

    it "redirects to the case" do
      expect(page).to have_current_path(support_case_path(support_case), ignore_query: true)
    end

    it "changes status of case to opened" do
      support_case.reload
      expect(support_case.state).to eq "opened"
    end

    it "records the case being moved from on_hold to open" do
      expect(activity_log_item.support_case_id).to eq support_case.id
      expect(activity_log_item.action).to eq "change_state"
      expect(activity_log_item.data).to eq({ "old_state" => "on_hold", "new_state" => "opened" })
    end

    it "records the interaction for case history" do
      expect(Support::Interaction.last.body).to eql "From on hold to open by Procurement Specialist on #{Time.zone.now.to_formatted_s(:short)}"
    end
  end
end
