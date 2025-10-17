require "rails_helper"

RSpec.describe Energy::GenerateDocumentsAndSendEmail do
  subject(:service) { described_class.new(onboarding_case:, current_user: user) }

  let(:vat_rate) { 5 }
  let(:support_organisation) { create(:support_organisation) }
  let(:user) { create(:user, :many_supported_schools_and_groups) }
  let(:support_case) { create(:support_case, organisation: support_organisation) }
  let(:onboarding_case) { create(:onboarding_case, support_case:) }
  let(:onboarding_case_organisation) { create(:energy_onboarding_case_organisation, onboarding_case:, onboardable: support_organisation, vat_rate:) }

  let(:loa_pdf) { instance_double(Energy::Documents::LetterOfAuthority, call: "LOA_PDF") }
  let(:mailer) { instance_double(Energy::Emails::OnboardingFormSubmissionMailer, call: true) }

  before do
    onboarding_case_organisation
    allow(Energy::Documents::LetterOfAuthority).to receive(:new).and_return(loa_pdf)
    allow(Energy::Emails::OnboardingFormSubmissionMailer).to receive(:new).and_return(mailer)
  end

  describe "#call" do
    context "when an error occurs during document generation" do
      before do
        allow(loa_pdf).to receive(:call).and_raise(StandardError.new("generation failed"))
        allow(Rails.logger).to receive(:error)
      end

      it "logs the error and re-raises it" do
        expect { service.call }.to raise_error(StandardError, "generation failed")
        expect(Rails.logger).to have_received(:error).with(/Error generating documents: generation failed/)
      end
    end
  end
end
