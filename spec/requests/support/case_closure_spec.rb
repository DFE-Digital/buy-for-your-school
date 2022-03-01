RSpec.describe "Case closure", type: :request do
  context "when agent signed in" do
    before do
      agent_is_signed_in
    end

    describe "attempting to close a case" do
      context "when the case is opened" do
        let(:support_case) { create(:support_case, :opened) }

        it "redirects to support_cases_path with the state unchanged" do
          post support_case_closure_path(support_case)
          expect(support_case.reload.state).to eq("opened")
          expect(response).to redirect_to(support_case_path(support_case))
        end
      end

      context "when the case is new" do
        let(:support_case) { create(:support_case, :initial) }

        it "redirects to support_cases_path with the state unchanged" do
          post support_case_closure_path(support_case)
          expect(support_case.reload.state).to eq("initial")
          expect(response).to redirect_to(support_case_path(support_case))
        end
      end

      context "when the case is on_hold" do
        let(:support_case) { create(:support_case, :on_hold) }

        it "redirects to support_cases_path with the state unchanged" do
          post support_case_closure_path(support_case)
          expect(support_case.reload.state).to eq("on_hold")
          expect(response).to redirect_to(support_case_path(support_case))
        end
      end
    end
  end
end
