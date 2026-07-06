require "./spec/support/shared/framework_request_controllers"

describe FrameworkRequests::DocumentUploadsController, type: :controller do
  include_examples "back url", "/procurement-support/documents"

  describe "on create" do
    it "redirects to the accessibility needs page" do
      post(:create)
      expect(response).to redirect_to "/procurement-support/special_requirements"
    end

    context "when the request is already submitted" do
      let(:framework_request) { create(:framework_request, submitted: true, category: create(:request_for_help_category, flow: "services")) }

      before do
        allow(controller).to receive(:framework_request).and_return(FrameworkRequestPresenter.new(framework_request))
        post(:create, session: { framework_request_id: framework_request.id })
      end

      it "redirects to the submission confirmation page" do
        expect(response).to redirect_to("/procurement-support-submissions/#{framework_request.id}")
      end
    end
  end

  describe "on update" do
    let(:framework_request) { create(:framework_request, category: create(:request_for_help_category, flow: "services")) }

    before do
      patch :update, params: { id: framework_request.id }
    end

    it "redirects to the check-your-answers page" do
      expect(response).to redirect_to("/procurement-support/#{framework_request.id}")
    end
  end

  describe "submitted request redirects" do
    let(:framework_request) { create(:framework_request, submitted: true, category: create(:request_for_help_category, flow: "services")) }

    it "redirects list requests to the submission confirmation page" do
      allow(controller).to receive(:framework_request).and_return(FrameworkRequestPresenter.new(framework_request))
      get(:list, params: { id: framework_request.id })
      expect(response).to redirect_to("/procurement-support-submissions/#{framework_request.id}")
    end

    it "redirects upload requests to the submission confirmation page" do
      allow(controller).to receive(:framework_request).and_return(FrameworkRequestPresenter.new(framework_request))
      post(:upload, params: { id: framework_request.id })
      expect(response).to redirect_to("/procurement-support-submissions/#{framework_request.id}")
    end

    it "redirects remove requests to the submission confirmation page" do
      allow(controller).to receive(:framework_request).and_return(FrameworkRequestPresenter.new(framework_request))
      delete(:remove, params: { id: framework_request.id, file_id: "123" })
      expect(response).to redirect_to("/procurement-support-submissions/#{framework_request.id}")
    end

    it "redirects edit requests to the submission confirmation page" do
      allow(controller).to receive(:framework_request).and_return(FrameworkRequestPresenter.new(framework_request))
      get(:edit, params: { id: framework_request.id })
      expect(response).to redirect_to("/procurement-support-submissions/#{framework_request.id}")
    end
  end

  describe "on edit" do
    let(:framework_request) { create(:framework_request, category: create(:request_for_help_category, flow: "services")) }

    context "when coming in from the check-your-answers page" do
      let(:framework_support_form) { { framework_support_form: { source: "change_link" } } }
      let(:params) { { id: framework_request.id, **framework_support_form } }

      before { get :edit, params: }

      it "goes back to the check-your-answers page" do
        expect(controller.view_assigns["back_url"]).to eq "/procurement-support/#{framework_request.id}"
      end
    end

    context "when coming in from elsewhere" do
      let(:params) { { id: framework_request.id } }

      before { get :edit, params: }

      it "goes back to the documents page" do
        expect(controller.view_assigns["back_url"]).to eq "/procurement-support/#{framework_request.id}/documents/edit"
      end
    end
  end
end
