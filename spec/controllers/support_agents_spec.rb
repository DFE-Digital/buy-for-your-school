describe SupportAgents, type: :controller do
  controller(ApplicationController) do
    include SupportAgents
    def protected_action = render plain: "You were able to access the Protected Action"
    def authorize_agent_scope = :access_proc_ops_portal?
  end

  before do
    routes.draw do
      get "protected_action" => "anonymous#protected_action"
    end
  end

  around do |example|
    ClimateControl.modify(PROC_OPS_TEAM: "DSI Caseworkers") do
      example.run
    end
  end

  let(:session) { { dfe_sign_in_uid: 12_345 } }

  describe "specifying agent auth scope" do
    before do
      # user must exist and be internal to trigger authorization
      create(:user, :caseworker, dfe_sign_in_uid: 12_345)
      allow(controller).to receive(:authorize).and_return(true)
    end

    it "authorizes the agent against the defined scope" do
      get(:protected_action, session:)
      expect(controller).to have_received(:authorize).with(:cms_portal, :access_proc_ops_portal?)
    end

    describe "you can also override the scope" do
      before do
        controller.instance_eval do
          def authorize_agent_scope = :another_scope
        end
      end

      it "authorizes the agent against the overridden scope" do
        get(:protected_action, session:)
        expect(controller).to have_received(:authorize).with(:cms_portal, :another_scope)
      end
    end
  end

  describe "#redirect_non_internal_users!" do
    context "when user is not internal" do
      it "redirects to the root_path" do
        create(:user, dfe_sign_in_uid: 12_345)
        get(:protected_action, session:)
        expect(response).to redirect_to(root_path)
      end
    end

    context "when user is internal" do
      it "does not redirect to root_path (user still to be authorized however)" do
        create(:user, :caseworker, dfe_sign_in_uid: 12_345)
        get(:protected_action, session:)
        expect(response).not_to redirect_to(root_path)
      end
    end
  end

  describe "rescuing from Pundit::NotAuthorizedError" do
    before do
      # user must exist and be internal to trigger authorization
      create(:user, :caseworker, dfe_sign_in_uid: 12_345)
      allow(controller).to receive(:authorize).and_raise(Pundit::NotAuthorizedError)
    end

    context "when agent has some roles" do
      it "redirects to cms_not_authorized_path" do
        create(:support_agent, dsi_uid: 12_345, roles: %w[global_admin])
        get(:protected_action, session:)
        expect(response).to redirect_to(cms_not_authorized_path)
      end
    end

    context "when agent has no roles yet" do
      it "redirects to cms_no_roles_assigned_path" do
        create(:support_agent, dsi_uid: 12_345, roles: [])
        get(:protected_action, session:)
        expect(response).to redirect_to(cms_no_roles_assigned_path)
      end
    end
  end

  describe "#current_agent" do
    before do
      user = create(:user, :caseworker, dfe_sign_in_uid: 12_345)
      allow(controller).to receive(:current_user).and_return(user)
    end

    context "when agent does not exist" do
      context "when the current_user is in proc ops organisation" do
        it "creates one based on the user" do
          expect { controller.current_agent }.to change { Support::Agent.where(dsi_uid: 12_345).count }.from(0).to(1)
        end
      end

      context "when the current_user is not in proc ops organisation" do
        before { User.find_by(dfe_sign_in_uid: 12_345).update(orgs: []) }

        it "does not create an agent as that would then class them as internal" do
          expect { controller.current_agent }.not_to change { Support::Agent.where(dsi_uid: 12_345).count }.from(0)
        end
      end
    end

    context "when agent already exists" do
      it "returns it" do
        support_agent = create(:support_agent, dsi_uid: 12_345)
        expect(controller.current_agent).to eq(support_agent)
      end
    end
  end
end
