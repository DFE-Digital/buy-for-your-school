require "rails_helper"

RSpec.describe Energy::Documents::LetterOfAuthority do
  it_behaves_like "with attachable PDF", "DfE Energy for Schools Letter of Agreement"

  describe "rendered HTML" do
    subject(:html) { described_class.new(onboarding_case:).send(:render_html) }

    let(:support_case) { create(:support_case, organisation: create(:support_organisation)) }
    let(:onboarding_case) { create(:onboarding_case, :submitted, support_case:) }

    it "is signed on behalf of DfE by the DfE contact" do
      expect(html).to include(I18n.t("energy.letter_of_authorisation.signed.signed_by_dfe"))
      expect(html).to include(Energy::DfeContact::FULL_NAME)
    end
  end
end
