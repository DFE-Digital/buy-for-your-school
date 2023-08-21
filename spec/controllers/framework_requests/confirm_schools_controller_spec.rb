require "./spec/support/shared/framework_request_controllers"

describe FrameworkRequests::ConfirmSchoolsController, type: :controller do
  let(:framework_request) { create(:framework_request) }
  let(:school_urns_confirmed) { false }
  let(:school_urns) { %w[1 2] }
  let(:framework_support_form) { { framework_support_form: { school_urns:, school_urns_confirmed: } } }
  let(:params) { framework_support_form }

  describe "create" do
    let(:session) { { framework_request_id: framework_request.id } }

    context "when the schools are confirmed" do
      let(:school_urns_confirmed) { true }

      context "and it is an energy request" do
        let(:framework_request) { create(:framework_request, :energy_request) }

        it "redirects to the bill upload page" do
          post(:create, params:, session:)
          expect(response).to redirect_to "/procurement-support/bill_uploads"
        end
      end

      context "and the user is signed in" do
        before { user_is_signed_in }

        it "redirects to the message page" do
          post(:create, params:, session:)
          expect(response).to redirect_to "/procurement-support/message"
        end
      end

      context "and the user is a guest" do
        it "redirects to the name page" do
          post(:create, params:, session:)
          expect(response).to redirect_to "/procurement-support/name"
        end
      end
    end

    context "when the schools are not confirmed" do
      let(:school_urns_confirmed) { false }

      it "redirects to the school picker page" do
        post(:create, params:, session:)
        expect(response).to redirect_to "/procurement-support/school_picker?#{{ framework_support_form: { school_urns: } }.to_query}"
      end
    end
  end

  describe "update" do
    let(:params) { { id: framework_request.id, **framework_support_form } }

    context "when the schools are confirmed" do
      let(:school_urns_confirmed) { true }

      it "redirects to the request" do
        patch(:update, params:)
        expect(response).to redirect_to "/procurement-support/#{framework_request.id}"
      end
    end

    context "when the schools are not confirmed" do
      let(:school_urns_confirmed) { false }

      it "redirects to the school picker page" do
        patch(:update, params:)
        expect(response).to redirect_to "/procurement-support/#{framework_request.id}/school_picker/edit"
      end
    end
  end

  describe "index" do
    describe "back url" do
      include_examples "back url", "/procurement-support/school_picker"
    end
  end

  describe "edit" do
    describe "back url" do
      let(:params) { { id: framework_request.id } }

      it "goes back to the school picker" do
        get(:edit, params:)
        expect(controller.view_assigns["back_url"]).to eq "/procurement-support/#{framework_request.id}/school_picker/edit"
      end
    end
  end
end
