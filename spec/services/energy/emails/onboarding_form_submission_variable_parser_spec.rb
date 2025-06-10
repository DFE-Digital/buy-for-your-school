require "rails_helper"

RSpec.describe Energy::Emails::OnboardingFormSubmissionVariableParser do
  subject(:service) { described_class.new(support_case, onboarding_case_organisation, email_draft) }

  let(:support_case) { create(:support_case) }
  let(:email_draft) { instance_double(Email::Draft, body: email_body) }

  let(:onboarding_case_organisation) do
    instance_double(
      Energy::OnboardingCaseOrganisation,
      gas_current_contract_end_date: gas_end_date,
      electric_current_contract_end_date: electricity_end_date,
      switching_energy_type_gas?: switching_gas,
      switching_energy_type_electricity?: switching_electricity,
      switching_energy_type_gas_electricity?: switching_both,
    )
  end

  let(:gas_end_date) { Date.new(2025, 6, 30) }
  let(:electricity_end_date) { Date.new(2025, 7, 15) }
  let(:switching_gas) { false }
  let(:switching_electricity) { false }
  let(:switching_both) { false }

  describe "#parse_template" do
    context "with a valid Liquid template" do
      let(:email_body) do
        <<~LIQUID
          Hello {{ case_creator_full_name }},
          Your reference number is {{ case_reference_number }}.
          Organisation: {{ organisation_name }}.
          Start dates: {{ gas_and_or_electricity_contract_start_dates }}
        LIQUID
      end

      context "with support case details" do
        it "renders dynamic attributes" do
          output = service.parse_template
          expect(output).to include(support_case.ref)
          expect(output).to include("#{support_case.first_name} #{support_case.last_name}")
        end
      end

      context "when switching gas only" do
        let(:switching_gas) { true }

        it "renders gas contract start date" do
          output = service.parse_template

          expect(output).to include("<span>01/07/2025 (gas)</span>")
          expect(output).not_to include("electricity")
        end
      end

      context "when switching electricity only" do
        let(:switching_electricity) { true }

        it "renders electricity contract start date" do
          output = service.parse_template
          expect(output).to include("<span>16/07/2025 (electricity)</span>")
          expect(output).not_to include("gas")
        end
      end

      context "when switching both gas and electricity" do
        let(:switching_both) { true }

        it "renders both gas and electricity contract start dates" do
          output = service.parse_template
          expect(output).to include("<span>01/07/2025 (gas)</span>")
          expect(output).to include("<span>16/07/2025 (electricity)</span>")
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
