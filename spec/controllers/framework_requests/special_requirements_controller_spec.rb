describe FrameworkRequests::SpecialRequirementsController, type: :controller do
  let(:framework_request) { create(:framework_request, category:) }
  let(:category) { create(:request_for_help_category, flow:) }
  let(:flow) { nil }

  it "redirects to the origin page" do
    params = { framework_support_form: { special_requirements_choice: "no" } }
    session = { framework_request_id: framework_request.id }
    post(:create, params:, session:)
    expect(response).to redirect_to "/procurement-support/origin?#{params.to_query}"
  end

  describe "back url" do
    context "when the request is in the energy flow" do
      context "and about electricity" do
        let(:category) { create(:request_for_help_category, slug: "electricity", flow: :energy) }

        context "and has bills" do
          before do
            framework_request.update!(energy_bills: create_list(:energy_bill, 1))
            get :index, session: { framework_request_id: framework_request.id }
          end

          it "goes back to the bill uploads page" do
            expect(controller.view_assigns["back_url"]).to eq "/procurement-support/bill_uploads"
          end
        end

        context "and does not have bills" do
          before { get :index, session: { framework_request_id: framework_request.id } }

          it "goes back to the energy alternative page" do
            expect(controller.view_assigns["back_url"]).to eq "/procurement-support/energy_alternative"
          end
        end
      end

      context "and about gas" do
        let(:category) { create(:request_for_help_category, slug: "gas", flow: :energy) }

        context "and has bills" do
          before do
            framework_request.update!(energy_bills: create_list(:energy_bill, 1))
            get :index, session: { framework_request_id: framework_request.id }
          end

          it "goes back to the bill uploads page" do
            expect(controller.view_assigns["back_url"]).to eq "/procurement-support/bill_uploads"
          end
        end

        context "and does not have bills" do
          before { get :index, session: { framework_request_id: framework_request.id } }

          it "goes back to the energy alternative page" do
            expect(controller.view_assigns["back_url"]).to eq "/procurement-support/energy_alternative"
          end
        end
      end

      context "and about anything else" do
        let(:category) { create(:request_for_help_category, slug: "water", flow: :energy) }

        context "and has documents" do
          before do
            framework_request.update!(documents: create_list(:document, 1))
            get :index, session: { framework_request_id: framework_request.id }
          end

          it "goes back to the document uploads page" do
            expect(controller.view_assigns["back_url"]).to eq "/procurement-support/document_uploads"
          end
        end

        context "and does not have documents" do
          before { get :index, session: { framework_request_id: framework_request.id } }

          it "goes back to the documents page" do
            expect(controller.view_assigns["back_url"]).to eq "/procurement-support/documents"
          end
        end
      end
    end

    context "when the request is in the services flow" do
      let(:category) { create(:request_for_help_category, slug: "legal_services", flow: :services) }

      context "and has documents" do
        before do
          framework_request.update!(documents: create_list(:document, 1))
          get :index, session: { framework_request_id: framework_request.id }
        end

        it "goes back to the document uploads page" do
          expect(controller.view_assigns["back_url"]).to eq "/procurement-support/document_uploads"
        end
      end

      context "and does not have documents" do
        before { get :index, session: { framework_request_id: framework_request.id } }

        it "goes back to the documents page" do
          expect(controller.view_assigns["back_url"]).to eq "/procurement-support/documents"
        end
      end
    end

    context "when the request is in any other flow" do
      let(:category) { create(:request_for_help_category, slug: "books", flow: :goods) }

      before { get :index, session: { framework_request_id: framework_request.id } }

      it "goes back to the message page" do
        expect(controller.view_assigns["back_url"]).to eq "/procurement-support/message"
      end
    end
  end
end
