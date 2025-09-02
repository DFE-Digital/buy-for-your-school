require "rails_helper"

RSpec.describe Energy::TasksController, type: :controller do
  describe "#authenticate_user!" do
    let(:support_organisation) { create(:support_organisation, urn: 100_253) }
    let(:user) { create(:user, :many_supported_schools_and_groups) }
    let(:support_case) { create(:support_case, organisation: support_organisation, email: user.email) }
    let(:onboarding_case) { create(:onboarding_case, support_case:) }
    let(:case_organisation) { create(:energy_onboarding_case_organisation, onboarding_case:, onboardable: support_organisation) }

    context "with guest user" do
      before do
        case_organisation
      end

      it "redirects to energy_start_path" do
        get(:show, params: { case_id: onboarding_case.id })

        expect(response).to redirect_to(energy_start_path)
        expect(session[:energy_case_tasks_path]).to eq(energy_case_tasks_path(case_id: onboarding_case.id))
      end
    end
  end
end
