require "./spec/support/shared/framework_request_controllers"

describe FrameworkRequests::ConfirmSchoolsController, type: :controller do
  let(:framework_request) { create(:framework_request, category:) }
  let(:school_urns_confirmed) { false }
  let(:school_urns) { %w[1 2] }
  let(:framework_support_form) { { framework_support_form: { school_urns:, school_urns_confirmed: } } }
  let(:category) { nil }
  let(:params) { framework_support_form }

  describe "create" do
    let(:session) { { framework_request_id: framework_request.id } }

    context "when the schools are confirmed" do
      let(:school_urns_confirmed) { true }

      context "and the user is signed in" do
        before { user_is_signed_in }

        it "redirects to the categories page" do
          post(:create, params:, session:)
          expect(response).to redirect_to "/procurement-support/categories"
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

      context "and a single school has been selected" do
        let(:school_urns) { %w[1] }

        it "redirects to the request" do
          patch(:update, params:)
          expect(response).to redirect_to "/procurement-support/#{framework_request.id}"
        end
      end

      context "and multiple schools have been selected" do
        let(:school_urns) { %w[1 2] }

        context "and the user is in the services flow" do
          let(:category) { create(:request_for_help_category, flow: :services) }

          it "redirects to the same supplier page" do
            patch(:update, params:)
            expect(response).to redirect_to "/procurement-support/#{framework_request.id}/same_supplier/edit"
          end
        end

        context "and the user is in the energy flow" do
          let(:category) { create(:request_for_help_category, flow: :energy) }

          it "redirects to the same supplier page" do
            patch(:update, params:)
            expect(response).to redirect_to "/procurement-support/#{framework_request.id}/same_supplier/edit"
          end
        end
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
