require "rails_helper"

RSpec.describe Energy::Emails::OnboardingFormDdTotalVariableParser do
  subject(:service) { described_class.new(support_case, onboarding_case_organisation, email_draft) }

  let(:support_case) { create(:support_case) }
  let(:email_draft) { instance_double(Email::Draft, body: email_body) }

  let(:onboarding_case_organisation) do
    instance_double(
      Energy::OnboardingCaseOrganisation,
      gas_current_contract_end_date: gas_end_date,
      switching_energy_type_gas?: switching_gas,
      switching_energy_type_gas_electricity?: switching_both,
      billing_payment_terms: "days14",
    )
  end

  let(:gas_end_date) { Date.new(2025, 6, 30) }
  let(:switching_gas) { false }
  let(:switching_both) { false }

  describe "#parse_template" do
    context "with a valid Liquid template" do
      let(:email_body) do
        <<~LIQUID
          Hello {{ case_creator_full_name }},
          billing payment terms is {{ billing_payment_terms }}.
          gas contract end date: {{ gas_contract_end_date }}
        LIQUID
      end

      context "with support case details" do
        it "renders dynamic attributes" do
          output = service.parse_template
          expect(output).to include("#{support_case.first_name} #{support_case.last_name}")
        end
      end

      context "when switching gas only" do
        let(:switching_gas) { true }

        it "renders gas end date" do
          output = service.parse_template
          expect(output).to include("01/07/2025")
          expect(output).to include("14 days")
        end
      end

      context "when switching both gas and electricity" do
        let(:switching_both) { true }

        it "renders gas end date" do
          output = service.parse_template
          expect(output).to include("01/07/2025")
          expect(output).to include("14 days")
        end
      end
    end

    context "with invalid Liquid syntax" do
      let(:email_body) { "Hello {{ invalid_var" }

      it "raises Liquid::SyntaxError" do
        expect { service.parse_template }.to raise_error(Liquid::SyntaxError)
      end
    end
  end
end
