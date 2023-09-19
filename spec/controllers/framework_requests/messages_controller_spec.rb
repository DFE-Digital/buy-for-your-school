require "./spec/support/shared/framework_request_controllers"

describe FrameworkRequests::MessagesController, type: :controller do
  let(:framework_request) { create(:framework_request, category:) }
  let(:category) { nil }

  include_examples "back url", "/procurement-support/procurement_amount"

  context "when the request is in the energy flow" do
    context "and about electricity" do
      let(:category) { create(:request_for_help_category, slug: "electricity", flow: :energy) }

      before { post :create, session: { framework_request_id: framework_request.id } }

      it "redirects to the energy bill page" do
        expect(response).to redirect_to "/procurement-support/energy_bill"
      end
    end

    context "and about gas" do
      let(:category) { create(:request_for_help_category, slug: "gas", flow: :energy) }

      before { post :create, session: { framework_request_id: framework_request.id } }

      it "redirects to the energy bill page" do
        expect(response).to redirect_to "/procurement-support/energy_bill"
      end
    end

    context "and about anything else" do
      let(:category) { create(:request_for_help_category, slug: "water", flow: :energy) }

      before { post :create, session: { framework_request_id: framework_request.id } }

      it "redirects to the documents page" do
        expect(response).to redirect_to "/procurement-support/documents"
      end
    end
  end

  context "when the request is in the services flow" do
    let(:category) { create(:request_for_help_category, slug: "catering-services", flow: :services) }

    before { post :create, session: { framework_request_id: framework_request.id } }

    it "redirects to the documents page" do
      expect(response).to redirect_to "/procurement-support/documents"
    end
  end

  context "when the request is in the goods flow" do
    let(:category) { create(:request_for_help_category, slug: "books", flow: :goods) }

    before { post :create, session: { framework_request_id: framework_request.id } }

    it "redirects to the accessibility needs page" do
      expect(response).to redirect_to "/procurement-support/special_requirements"
    end
  end

  context "when the request is in the not-fully-supported flow" do
    let(:category) { create(:request_for_help_category, slug: "uniform", flow: :not_fully_supported) }

    before { post :create, session: { framework_request_id: framework_request.id } }

    it "redirects to the accessibility needs page" do
      expect(response).to redirect_to "/procurement-support/special_requirements"
    end
  end
end
