require "rails_helper"

RSpec.describe "school buyer signin request", type: :request do
  let(:support_case) { create(:support_case) }

  describe "GET my_procurements_task_path" do
    context "when user is not signed in" do
      it "redirects to the my_procurements_signin_path" do
        get my_procurements_task_path(support_case)
        expect(response).to redirect_to(my_procurements_signin_path(support_case))
      end
    end
  end
end
