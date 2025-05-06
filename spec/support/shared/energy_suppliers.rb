RSpec.shared_context "with energy suppliers" do
  let(:support_organisation) { create(:support_organisation, urn: 100_253) }
  let(:user) { create(:user, :many_supported_schools_and_groups) }
  let(:support_case) { create(:support_case, organisation: support_organisation) }
  let(:onboarding_case) { create(:onboarding_case, support_case:) }
  let(:case_organisation) { create(:energy_onboarding_case_organisation, onboarding_case:, onboardable: support_organisation) }

  let(:expected_suppliers) do
    [
      "British Gas",
      "EDF Energy",
      "E.ON Next",
      "Scotish Power",
      "OVO Energy",
      "Octopus Energy",
      "Other",
    ]
  end
end
