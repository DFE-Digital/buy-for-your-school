require "./spec/support/shared/framework_request_controllers"

describe FrameworkRequests::CategoriesController, type: :controller do
  let(:framework_request) { create(:framework_request, category:, group:, org_id:) }
  let(:category) { nil }
  let(:group) { nil }
  let(:org_id) { nil }

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
        context "and the user is signed in" do
          before { user_is_signed_in(user:) }

          context "and the user belongs to a MAT or federation with multiple schools" do
            let(:user) { build(:user, :one_supported_group) }
            let(:group) { true }
            let(:org_id) { "2314" }

            before do
              establishment_group_type = create(:support_establishment_group_type, code: 6)
              create(:support_establishment_group, name: "Testing Multi Academy Trust", uid: "2314", establishment_group_type:)
              create_list(:support_organisation, 2, trust_code: "2314")
              get :index, session: { framework_request_id: framework_request.id }
            end

            it "goes back to the schools confirmation page" do
              expect(controller.view_assigns["back_url"]).to eq "/procurement-support/confirm_schools"
            end
          end

          context "and the user belongs to a single chosen organisation" do
            let(:user) { build(:user, :many_supported_schools) }

            before { get :index, session: { framework_request_id: framework_request.id } }

            it "goes back to the select organisation page" do
              expect(controller.view_assigns["back_url"]).to eq "/procurement-support/select_organisation"
            end
          end

          context "and the user belongs to a single inferred organisation" do
            let(:user) { build(:user, :one_supported_school) }

            before { get :index, session: { framework_request_id: framework_request.id } }

            it "goes back to the confirm sign-in page" do
              expect(controller.view_assigns["back_url"]).to eq "/procurement-support/confirm_sign_in"
            end
          end
        end

        context "and the user is a guest" do
          before { get :index, session: { framework_request_id: framework_request.id } }

          it "goes back to the email page" do
            expect(controller.view_assigns["back_url"]).to eq "/procurement-support/email"
          end
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
      before do
        c.update!(flow:)
        post :create, params: { category_path: "a/b", framework_support_form: { category_slug: "c" } }, session: { framework_request_id: framework_request.id }
      end

      context "and they are in the services flow" do
        let(:flow) { :services }

        it "redirects to the contract length page" do
          expect(response).to redirect_to("/procurement-support/contract_length")
        end
      end

      context "and they are in the energy flow" do
        let(:flow) { :energy }

        it "redirects to the contract length page" do
          expect(response).to redirect_to("/procurement-support/contract_length")
        end
      end

      context "and they are not in the energy or services flow" do
        let(:flow) { :goods }

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

      it "persists the final category" do
        expect { patch_action }.to change { framework_request.reload.category }.from(nil).to(c)
      end

      context "and the flow is finished" do
        it "redirects to the check-your-answers page" do
          patch_action
          expect(response).to redirect_to("/procurement-support/#{framework_request.id}")
        end
      end

      context "and the flow is unfinished" do
        let(:category) { create(:request_for_help_category, slug: "d", flow: :goods) }
        let(:e) { create(:request_for_help_category, slug: "e", parent: b, flow: :services) }

        before do
          patch :update, params: { id: framework_request.id, category_path: "a/b", framework_support_form: { category_slug: e.slug } }
        end

        it "redirects to the contract length page" do
          expect(response).to redirect_to("/procurement-support/#{framework_request.id}/contract_length/edit")
        end
      end
    end
  end
end
