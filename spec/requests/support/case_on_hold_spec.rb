RSpec.describe "Case being changed to open", type: :request do
  context "when agent signed in" do
    before do
      agent_is_signed_in
    end

    describe "attempting to place a case on hold" do
      context "when the case is resolved" do
        let(:support_case) { create(:support_case, :resolved) }

        it "redirects to support_cases_path with the state unchanged" do
          post support_case_on_hold_path(support_case)
          expect(support_case.reload.state).to eq("resolved")
          expect(response).to redirect_to(support_case_path(support_case))
        end
      end

      context "when the case is closed" do
        let(:support_case) { create(:support_case, :closed) }

        it "redirects to support_cases_path with the state unchanged" do
          post support_case_on_hold_path(support_case)
          expect(support_case.reload.state).to eq("closed")
          expect(response).to redirect_to(support_case_path(support_case))
        end
      end
    end
  end
end
