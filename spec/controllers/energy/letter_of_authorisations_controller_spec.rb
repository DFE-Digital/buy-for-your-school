require "rails_helper"

RSpec.describe Energy::LetterOfAuthorisationsController, type: :controller do
  let(:support_organisation) { create(:support_organisation, urn: 100_253) }
  let(:user) { create(:user, :many_supported_schools) }
  let(:support_case) { create(:support_case, organisation: support_organisation, email: user.email) }
  let(:onboarding_case) { create(:onboarding_case, support_case:) }
  let(:case_organisation) do
    create(:energy_onboarding_case_organisation, :with_energy_details, onboarding_case:, onboardable: support_organisation)
  end
  let(:letter_of_authorisation_form) { { loa_agreed: %w[agreement1 agreement2 agreement3] } }
  let(:mailer_double) { instance_double(Energy::Emails::OnboardingFormSubmissionMailer, call: true) }

  before do
    ActiveJob::Base.queue_adapter = :test

    case_organisation
    user_is_signed_in(user:)
    allow(Energy::Emails::OnboardingFormSubmissionMailer).to receive(:new).and_return(mailer_double)
  end

  describe "GET #show" do
    it "renders the show template" do
      get(:show, params: { case_id: case_organisation.onboarding_case.id })

      expect(response.status).to eq(200)
      expect(response).to render_template(:show)
    end
  end

  describe "PATCH #update" do
    context "with valid params" do
      it "updates the organisation loa attributes" do
        patch(:update, params: { case_id: onboarding_case.id, letter_of_authorisation_form: })

        expect(response.status).to eq(302)
        expect(response).to redirect_to(energy_case_confirmation_path)
      end
    end
  end
end
