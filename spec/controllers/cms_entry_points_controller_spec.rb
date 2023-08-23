require "rails_helper"

describe CmsEntryPointsController do
  let(:session) { { dfe_sign_in_uid: 12_345 } }

  around do |example|
    ClimateControl.modify(PROC_OPS_TEAM: "DSI Caseworkers") do
      example.run
    end
  end

  describe "visiting the main entry point" do
    context "when user is not internal" do
      it "redirects to the root_path" do
        create(:user, dfe_sign_in_uid: 12_345)
        get(:start, session:)
        expect(response).to redirect_to(root_path)
      end
    end

    context "when user is internal" do
      context "when no agent exists due to first time login" do
        before { create(:user, :caseworker, dfe_sign_in_uid: 12_345) }

        it "creates the agent and redirects them to the no roles page" do
          expect { get :start, session: }.to change { Support::Agent.where(dsi_uid: 12_345).count }.from(0).to(1)
          expect(response).to redirect_to(cms_no_roles_assigned_path)
        end
      end

      context "when agent exists for user" do
        before do
          user = create(:user, :caseworker, dfe_sign_in_uid: 12_345)
          agent = Support::Agent.find_or_create_by_user(user)
          agent.update!(roles:)
          get :start, session:
        end

        home_paths = {
          "global_admin" => :support_root_path,
          "procops_admin" => :support_root_path,
          "procops" => :support_root_path,
          "e_and_o_admin" => :engagement_root_path,
          "e_and_o" => :engagement_root_path,
          "internal" => :support_root_path,
          "analyst" => :support_case_statistics_path,
          "framework_evaluator" => :frameworks_root_path,
        }

        home_paths.each do |role, home_path|
          context "when agent has role #{role} assigned" do
            let(:roles) { [role] }

            it "redirects to #{home_path}" do
              expect(response).to redirect_to(send(home_path))
            end
          end
        end

        context "when agent has no roles assigned" do
          let(:roles) { [] }

          it "redirects to cms_no_roles_assigned_path" do
            expect(response).to redirect_to(cms_no_roles_assigned_path)
          end
        end

        context "when agent has both e_and_o and procops roles" do
          let(:roles) { %w[e_and_o procops] }

          it "still redirects to support_root_path" do
            expect(response).to redirect_to(support_root_path)
          end
        end
      end
    end
  end
end
