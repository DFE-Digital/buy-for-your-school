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

    context "but there are other cases using some of it's meter numbers" do
      before do
        # Meters on this case
        create(:energy_gas_meter, :with_valid_data, onboarding_case_organisation: ob_org, mprn:)
        create(:energy_electricity_meter, :with_valid_data, onboarding_case_organisation: ob_org, mpan:)

        # Meters on other case
        create(:energy_gas_meter, :with_valid_data, onboarding_case_organisation: other_onboarding_case_organisation, mprn:)
        create(:energy_electricity_meter, :with_valid_data, onboarding_case_organisation: other_onboarding_case_organisation, mpan:)
      end

      let(:support_case) { create(:support_case, :closed) }
      let(:other_support_case) { create(:support_case) }
      let(:ob_case) { create(:onboarding_case, support_case:) }
      let(:ob_org) { create(:energy_onboarding_case_organisation, onboarding_case: ob_case, onboardable: support_case.organisation) }
      let(:mprn) { "123456789" }
      let(:mpan) { "0123456789123" }
      let(:other_onboarding_case) { create(:onboarding_case, support_case: other_support_case) }
      let(:other_onboarding_case_organisation) { create(:energy_onboarding_case_organisation, onboarding_case: other_onboarding_case, onboardable: other_support_case.organisation) }

      it "redirects to the case with error message" do
        visit current_path # Ensures the page is reloaded
        click_on "Reopen the case"
        expect(page).to have_current_path(cec_onboarding_case_path(support_case), ignore_query: true)
        expect(page).to have_text("Case cannot be reopened because one or more meter numbers are in use in other cases")
      end
    end
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
