RSpec.describe "Case closure", type: :request do
  context "when agent signed in" do
    before do
      agent_is_signed_in
    end

    describe "attempting to close a case" do
      context "when the case is opened" do
        let(:support_case) { create(:support_case, :opened) }

        it "redirects to support_cases_path with the state changed" do
          post support_case_support_case_closures_path(support_case), params: {
            case_closure_form: {
              reason: "no_engagement",
            },
          }
          expect(support_case.reload.state).to eq("closed")
          expect(support_case.closure_reason).to eq("no_engagement")
          expect(response).to redirect_to(support_cases_path)
        end
      end

      context "when the case is new and an incoming email" do
        let(:support_case) { create(:support_case, :initial, source: :incoming_email) }

        it "redirects to support_cases_path with the state unchanged" do
          post support_case_support_case_closures_path(support_case), params: {
            case_closure_form: {
              reason: "test_case",
            },
          }
          expect(support_case.reload.state).to eq("closed")
          expect(support_case.closure_reason).to eq("test_case")
          expect(response).to redirect_to(support_cases_path)
        end
      end

      context "when the case is new and not an incoming email" do
        let(:support_case) { create(:support_case, :initial, source: :digital) }

        it "redirects to support_cases_path with the state unchanged" do
          get support_case_closures_path(support_case)
          expect(support_case.reload.state).to eq("initial")
          expect(response).to redirect_to(support_cases_path)
        end
      end

      context "when the case is on_hold" do
        let(:support_case) { create(:support_case, :on_hold) }

        it "redirects to support_cases_path with the state unchanged" do
          get support_case_closures_path(support_case)
          expect(support_case.reload.state).to eq("on_hold")
          expect(response).to redirect_to(support_cases_path)
        end
      end
    end
  end
end
