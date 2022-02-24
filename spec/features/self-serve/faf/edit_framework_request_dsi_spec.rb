RSpec.feature "Editing a 'Find a Framework' request" do
  before do
    create(:support_organisation, urn: "100253", name: "Specialist School for Testing")
    create(:support_organisation, urn: "100254", name: "Greendale Academy for Bright Sparks")
    create(:support_establishment_group, establishment_group_type: create(:support_establishment_group_type))
  end

  context "when signed in" do
    let(:framework_request) do
      create(:framework_request, user: user, school_urn: "100253", group_uid: nil)
    end

    context "and the user has one supported school" do
      let(:user) { create(:user, :one_supported_school) }

      before do
        user_is_signed_in(user: user)
        visit "/procurement-support/#{framework_request.id}"
      end

      it "the school can not be edited" do
        within(all("div.govuk-summary-list__row")[2]) do
          expect(find("dd.govuk-summary-list__actions")).not_to have_link "Change"
        end
      end
    end

    context "and the user has many supported schools" do
      let(:user) { create(:user, :many_supported_schools) }

      before do
        user_is_signed_in(user: user)
        visit "/procurement-support/#{framework_request.id}"
      end

      it "the school can be edited" do
        click_link "edit-school"

        expect(page).to have_current_path "/procurement-support/#{framework_request.id}/edit?step=3"
        expect(find("input#framework-support-form-school-urn-100253-field")).to be_checked

        choose "Greendale Academy for Bright Sparks"
        click_continue

        expect(all("dd.govuk-summary-list__value")[2]).to have_text "Greendale Academy for Bright Sparks"
      end
    end
  end
end
