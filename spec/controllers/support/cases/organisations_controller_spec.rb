describe Support::Cases::OrganisationsController, type: :controller do
  before { agent_is_signed_in }

  describe "on update" do
    context "when the case has participating schools" do
      let(:establishment_group) { create(:support_establishment_group, uid: "123") }
      let(:participating_school) { create(:support_organisation, trust_code: "123") }
      let(:support_case) { create(:support_case, organisation: establishment_group) }
      let(:organisation_new) { create(:support_organisation) }

      before do
        create(:support_case_organisation, case: support_case, organisation: participating_school)
      end

      it "redirects to the organisation confirmation page" do
        patch(:update, params: { case_id: support_case.id, case_organisation_form: { organisation_id: organisation_new.id, organisation_type: organisation_new.class.name } })
        expect(response).to redirect_to "/support/cases/#{support_case.id}/confirm_organisation/#{organisation_new.id}?type=#{CGI.escape(organisation_new.class.name)}"
      end
    end
  end
end
