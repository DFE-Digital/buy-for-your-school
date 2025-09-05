require "rails_helper"

RSpec.describe Energy::Emails::OnboardingFormVatEdfVariableParser do
  subject(:service) { described_class.new(support_case, onboarding_case_organisation, email_draft) }

  let(:support_case) { create(:support_case) }
  let(:email_draft) { instance_double(Email::Draft, body: email_body) }

  let(:onboarding_case_organisation) do
    instance_double(
      Energy::OnboardingCaseOrganisation,
    )
  end

  describe "#parse_template" do
    context "with a valid Liquid template" do
      let(:email_body) do
        <<~LIQUID
          Hello {{ case_creator_first_name }},
        LIQUID
      end

      context "with support case details" do
        it "renders dynamic attributes" do
          output = service.parse_template
          expect(output).to include(support_case.first_name.to_s)
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
