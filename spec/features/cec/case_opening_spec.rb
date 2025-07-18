RSpec.feature "Case worker can open a case" do
  include_context "with a cec agent"

  before do
    visit cec_onboarding_case_path(support_case)
    click_link "Reopen case"
  end

  shared_examples "a reopened case" do |initial_state, old_state|
    let(:support_case) { create(:support_case, initial_state) }
    let(:activity_log_item) { Support::ActivityLogItem.last }

    it "redirects to the dialog" do
      expect(page).to have_current_path(cec_case_new_opening_path(support_case), ignore_query: true)
    end

    it "redirects to the case and successfully change status to opened" do
      visit current_path # Ensures the page is reloaded
      click_on "Reopen the case"
      expect(page).to have_current_path(cec_onboarding_case_path(support_case), ignore_query: true)
    end

    it "records the case being reopened" do
      visit current_path # Ensures the page is reloaded
      click_on "Reopen the case"
      expect(page).to have_current_path(cec_onboarding_case_path(support_case), ignore_query: true)

      support_case.reload
      expect(support_case.state).to eq "opened"
      expect(activity_log_item.support_case_id).to eq support_case.id
      expect(activity_log_item.action).to eq "change_state"
      expect(activity_log_item.data).to eq({ "old_state" => old_state, "new_state" => "opened" })
    end
  end

  context "when re-opening a case from resolved" do
    it_behaves_like "a reopened case", :resolved, "resolved"
  end

  context "when re-opening a case from closed" do
    it_behaves_like "a reopened case", :closed, "closed"
  end

  context "when a case is on hold" do
    let(:support_case) { create(:support_case, :on_hold) }
    let(:activity_log_item) { Support::ActivityLogItem.last }

    it "redirects to the case" do
      expect(page).to have_current_path(cec_onboarding_case_path(support_case), ignore_query: true)
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
