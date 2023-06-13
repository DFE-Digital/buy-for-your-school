require "./spec/support/shared/framework_request_controllers"

describe FrameworkRequests::CategoriesController, type: :controller do
  let(:framework_request) { create(:framework_request, category:, is_energy_request:, energy_request_about:, have_energy_bill:) }
  let(:category) { nil }
  let(:is_energy_request) { false }
  let(:energy_request_about) { nil }
  let(:have_energy_bill) { false }

  let(:a) { create(:request_for_help_category, slug: "a") }
  let(:b) { create(:request_for_help_category, slug: "b", parent: a) }
  let!(:c) { create(:request_for_help_category, slug: "c", parent: b) }

  describe "back url" do
    describe "on index" do
      context "when the user has chosen 'multiple' categories" do
        before { get :index, params: { category_path: "multiple" }, session: { framework_request_id: framework_request.id } }

        it "goes back to the main categories page" do
          expect(controller.view_assigns["back_url"]).to eq "/procurement-support/categories?#{{ framework_support_form: { category_slug: 'multiple' } }.to_query}"
        end
      end

      context "when the user is on the main categories page" do
        before { get :index, session: { framework_request_id: framework_request.id } }

        it "goes back to the message page" do
          expect(controller.view_assigns["back_url"]).to eq "/procurement-support/message"
        end
      end

      context "when the user has chosen a category with a parent" do
        let(:category) { c }

        before { get :index, params: { category_path: "a/b" }, session: { framework_request_id: framework_request.id } }

        it "goes back to the parent category" do
          expect(controller.view_assigns["back_url"]).to eq "/procurement-support/categories/a"
        end
      end
    end

    describe "on edit" do
      context "when the user has chosen 'multiple' categories" do
        before { get :edit, params: { id: framework_request.id, category_path: "multiple" } }

        it "goes back to the main categories page" do
          expect(controller.view_assigns["back_url"]).to eq "/procurement-support/#{framework_request.id}/category/edit?#{{ framework_support_form: { category_slug: 'multiple' } }.to_query}"
        end
      end

      context "when the user is on the main categories page" do
        before { get :edit, params: { id: framework_request.id } }

        it "goes back to the check-your-answers page" do
          expect(controller.view_assigns["back_url"]).to eq "/procurement-support/#{framework_request.id}"
        end
      end

      context "when the user has chosen a category with a parent" do
        let(:category) { c }

        before { get :edit, params: { id: framework_request.id, category_path: "a/b" } }

        it "goes back to the parent category" do
          expect(controller.view_assigns["back_url"]).to eq "/procurement-support/#{framework_request.id}/category/edit/a?#{{ framework_support_form: { category_slug: 'b' } }.to_query}"
        end
      end
    end
  end

  describe "on create" do
    context "when the user has not chosen a category" do
      before { post :create, params: { framework_support_form: { category_slug: nil } }, session: { framework_request_id: framework_request.id } }

      it "does not redirect" do
        expect(response).not_to be_redirect
      end
    end

    context "when the user has chosen an intermediate category" do
      let(:post_action) { post(:create, params: { category_path: "a", framework_support_form: { category_slug: "b" } }, session: { framework_request_id: framework_request.id }) }

      it "redirects to the next category in the hierarchy" do
        post_action
        expect(response).to redirect_to("/procurement-support/categories/a/b")
      end

      it "persists the intermediate category" do
        expect { post_action }.to change { framework_request.reload.category }.from(nil).to(b)
      end
    end

    context "when the user has chosen a final category" do
      before { post :create, params: { category_path: "a/b", framework_support_form: { category_slug: "c" } }, session: { framework_request_id: framework_request.id } }

      context "and they have chosen to upload a bill" do
        let(:is_energy_request) { true }
        let(:energy_request_about) { "energy_contract" }
        let(:have_energy_bill) { true }

        it "redirects to the accessibility page" do
          expect(response).to redirect_to("/procurement-support/special_requirements")
        end
      end

      context "and they have chosen not to upload a bill" do
        let(:is_energy_request) { false }
        let(:energy_request_about) { nil }
        let(:have_energy_bill) { false }

        it "redirects to the procurement amount page" do
          expect(response).to redirect_to("/procurement-support/procurement_amount")
        end
      end
    end
  end

  describe "on update" do
    context "when the user has not chosen a category" do
      before { patch :update, params: { id: framework_request.id, framework_support_form: { category_slug: nil } } }

      it "does not redirect" do
        expect(response).not_to be_redirect
      end
    end

    context "when the user has chosen an intermediate category" do
      let(:patch_action) { patch :update, params: { id: framework_request.id, category_path: "a", framework_support_form: { category_slug: "b" } } }

      it "redirects to the next category in the hierarchy" do
        patch_action
        expect(response).to redirect_to("/procurement-support/#{framework_request.id}/category/edit/a/b")
      end

      it "does not persist the intermediate category" do
        expect { patch_action }.not_to change { framework_request.reload.category }.from(nil)
      end
    end

    context "when the user has chosen a final category" do
      let(:patch_action) { patch :update, params: { id: framework_request.id, category_path: "a/b", framework_support_form: { category_slug: "c" } } }

      it "redirects to the check-your-answers page" do
        patch_action
        expect(response).to redirect_to("/procurement-support/#{framework_request.id}")
      end

      it "persists the final category" do
        expect { patch_action }.to change { framework_request.reload.category }.from(nil).to(c)
      end
    end
  end
end
