require "rails_helper"

describe FrameworkRequests::FrameworkRequestSubmissionsController, type: :controller do
  render_views

  describe "on update" do
    let(:framework_request) { create(:framework_request, category: create(:request_for_help_category, flow: "services")) }

    before do
      submitter = instance_double(SubmitFrameworkRequest, call: true)
      allow(SubmitFrameworkRequest).to receive(:new).and_return(submitter)
      patch :update, params: { id: framework_request.id }
    end

    it "redirects to the submission confirmation page" do
      expect(response).to redirect_to("/procurement-support-submissions/#{framework_request.id}")
    end

    it "stores the framework email for the confirmation page" do
      expect(session[:framework_request_email]).to eq(framework_request.email)
    end
  end

  describe "on show" do
    let(:framework_request) { create(:framework_request, submitted: true, category: create(:request_for_help_category, flow: "services")) }

    context "when the email was set by the submission flow" do
      before do
        session[:framework_request_email] = framework_request.email
        get :show, params: { id: framework_request.id }
      end

      it "exposes the email to the view" do
        expect(controller.view_assigns["email"]).to eq(framework_request.email)
      end

      it "removes the email from the session" do
        expect(session[:framework_request_email]).to be_nil
      end

      it "shows the email in the confirmation page" do
        expect(response.body).to include(framework_request.email)
      end
    end

    context "when the page is reached directly" do
      before do
        get :show, params: { id: framework_request.id }
      end

      it "does not expose the email to the view" do
        expect(controller.view_assigns["email"]).to be_nil
      end

      it "does not render the email in the confirmation page" do
        expect(response.body).not_to include(framework_request.email)
      end
    end
  end
end
