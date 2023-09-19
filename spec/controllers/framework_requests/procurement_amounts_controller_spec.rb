describe FrameworkRequests::ProcurementAmountsController, type: :controller do
  let(:framework_request) { create(:framework_request, category: create(:request_for_help_category, flow:)) }
  let(:flow) { nil }

  it "redirects to the message page" do
    post :create, params: { framework_support_form: { procurement_amount: "205.13" } }
    expect(response).to redirect_to "/procurement-support/message"
  end

  describe "back url" do
    describe "on index" do
      context "when the user is in the services flow" do
        let(:flow) { "services" }

        context "and it is not a multi-school request" do
          before { get :index, session: { framework_request_id: framework_request.id } }

          it "goes back to the contract start date page" do
            expect(controller.view_assigns["back_url"]).to eq "/procurement-support/contract_start_date"
          end
        end

        context "and it is a multi-school request" do
          before do
            framework_request.update!(school_urns: %w[1 2])
            get :index, session: { framework_request_id: framework_request.id }
          end

          it "goes back to the same supplier page" do
            expect(controller.view_assigns["back_url"]).to eq "/procurement-support/same_supplier"
          end
        end
      end

      context "when the user is in the energy flow" do
        let(:flow) { "energy" }

        context "and it is not a multi-school request" do
          before { get :index, session: { framework_request_id: framework_request.id } }

          it "goes back to the contract start date page" do
            expect(controller.view_assigns["back_url"]).to eq "/procurement-support/contract_start_date"
          end
        end

        context "and it is a multi-school request" do
          before do
            framework_request.update!(school_urns: %w[1 2])
            get :index, session: { framework_request_id: framework_request.id }
          end

          it "goes back to the same supplier page" do
            expect(controller.view_assigns["back_url"]).to eq "/procurement-support/same_supplier"
          end
        end
      end

      context "when the user is in a different flow" do
        let(:flow) { "goods" }

        before { get :index, session: { framework_request_id: framework_request.id } }

        it "goes back to the categories page" do
          expect(controller.view_assigns["back_url"]).to eq "/procurement-support/categories"
        end
      end
    end
  end
end
