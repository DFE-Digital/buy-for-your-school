describe FrameworkRequests::ContractStartDatesController, type: :controller do
  let(:framework_request) { create(:framework_request) }

  it "goes back to the contract length page" do
    get(:index, params: { framework_support_form: { contract_start_date_known: nil } })
    expect(controller.view_assigns["back_url"]).to eq "/procurement-support/contract_length"
  end

  describe "on create" do
    let(:params) { { framework_support_form: { contract_start_date_known: "true", "contract_start_date(3i)": "27", "contract_start_date(2i)": "3", "contract_start_date(1i)": "2023" } } }
    let(:session) { { framework_request_id: framework_request.id } }

    context "when multiple schools are selected" do
      before { framework_request.update!(school_urns: %w[1 2]) }

      it "redirects to the all schools same supplier page" do
        post(:create, params:, session:)
        expect(response).to redirect_to "/procurement-support/same_supplier"
      end
    end

    context "when a single organisation is selected" do
      it "redirects to the procurement amount page" do
        post(:create, params:, session:)
        expect(response).to redirect_to "/procurement-support/procurement_amount"
      end
    end
  end

  describe "on edit" do
    let(:framework_request) { create(:framework_request, category: create(:request_for_help_category, flow: "services"), contract_length: :one_year, contract_start_date_known: false) }

    context "when the flow is unfinished" do
      before do
        get :edit, params: { id: framework_request.id }
      end

      it "goes back to the contract length page" do
        expect(controller.view_assigns["back_url"]).to eq "/procurement-support/#{framework_request.id}/contract_length/edit"
      end
    end

    context "when the flow is finished" do
      before do
        framework_request.update!(document_types: %w[none])
        get :edit, params: { id: framework_request.id }
      end

      it "goes back to the check-your-answers page" do
        expect(controller.view_assigns["back_url"]).to eq "/procurement-support/#{framework_request.id}"
      end
    end
  end

  describe "on update" do
    let(:framework_request) { create(:framework_request, contract_length: :one_year, category:) }
    let(:category) { create(:request_for_help_category, flow: "services") }

    context "when the flow is unfinished" do
      context "and the organisation is a MAT with multiple selected schools" do
        before do
          framework_request.update!(school_urns: %w[1 2])
          patch :update, params: { id: framework_request.id, framework_support_form: { contract_start_date_known: "true", "contract_start_date(3i)": "27", "contract_start_date(2i)": "3", "contract_start_date(1i)": "2023" } }
        end

        it "redirects to the same supplier page" do
          expect(response).to redirect_to("/procurement-support/#{framework_request.id}/same_supplier/edit")
        end
      end

      context "and the organisation is a single school" do
        before do
          patch :update, params: { id: framework_request.id, framework_support_form: { contract_start_date_known: "true", "contract_start_date(3i)": "27", "contract_start_date(2i)": "3", "contract_start_date(1i)": "2023" } }
        end

        context "and the user has chosen gas or electricity" do
          let(:category) { create(:request_for_help_category, slug: "electricity", flow: "energy") }

          before do
            patch :update, params: { id: framework_request.id, framework_support_form: { contract_start_date_known: false } }
          end

          it "redirects to the energy bill page" do
            expect(response).to redirect_to("/procurement-support/#{framework_request.id}/energy_bill/edit")
          end
        end

        context "and the user has chosen a service or a different energy category" do
          before do
            patch :update, params: { id: framework_request.id, framework_support_form: { contract_start_date_known: false } }
          end

          it "redirects to the documents page" do
            expect(response).to redirect_to("/procurement-support/#{framework_request.id}/documents/edit")
          end
        end
      end
    end

    context "when the flow is finished" do
      before do
        framework_request.update!(document_types: %w[none])
        patch :update, params: { id: framework_request.id, framework_support_form: { contract_start_date_known: "true", "contract_start_date(3i)": "27", "contract_start_date(2i)": "3", "contract_start_date(1i)": "2023" } }
      end

      it "redirects to the check-your-answers page" do
        expect(response).to redirect_to("/procurement-support/#{framework_request.id}")
      end
    end
  end
end
