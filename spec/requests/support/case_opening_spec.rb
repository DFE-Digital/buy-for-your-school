RSpec.describe "Case being changed to open", type: :request do
  context "when agent signed in" do
    before do
      agent_is_signed_in
    end

    describe "attempting to open a case" do
      context "when the case is closed" do
        let(:support_case) { create(:support_case, :closed) }

        it "redirects to support_cases_path with the state unchanged" do
          post support_case_opening_path(support_case)
          expect(support_case.reload.state).to eq("opened")
          expect(response).to redirect_to(support_case_path(support_case).concat("#case-history"))
        end
      end
    end
  end
end
