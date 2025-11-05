require "rails_helper"

RSpec.describe Energy::Emails::NonDirectDebitVatTotalVariableParser do
  subject(:service) { described_class.new(support_case, onboarding_case_organisation, email_draft) }

  let(:support_case) { create(:support_case) }
  let(:email_draft) { instance_double(Email::Draft, body: email_body) }
  let(:total_energies_vat_email) { Energy::Emails::NonDirectDebitVatTotalMailer::TOTAL_ENERGIES_VAT_EMAIL }

  let(:onboarding_case_organisation) do
    instance_double(
      Energy::OnboardingCaseOrganisation,
      switching_energy_type_gas?: switching_gas,
      billing_payment_terms: "days14",
    )
  end

  let(:switching_gas) { true }

  describe "#parse_template" do
    context "with a valid Liquid template" do
      let(:email_body) do
        <<~LIQUID
          Hello {{ case_creator_full_name }},
          Your new gas contract is about to start.
          VAT relief email: "#{total_energies_vat_email}"
        LIQUID
      end

      context "with support case details" do
        it "renders dynamic attributes" do
          output = service.parse_template
          expect(output).to include(support_case.case_creator_full_name.to_s)
          expect(output).to include(total_energies_vat_email)
        end
      end
    end
  end
end
