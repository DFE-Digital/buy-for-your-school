RSpec.shared_context "with schools and groups" do
  let(:user) { create(:user, :many_supported_schools_and_groups) }

  # School types
  let(:community) { create(:support_establishment_type, name: "Community school") }
  let(:foundation) { create(:support_establishment_type, name: "Foundation school") }

  # Group types
  let(:sat) { create(:support_establishment_group_type, name: "Single-academy Trust", code: 10) }
  let(:mat) { create(:support_establishment_group_type, name: "Multi-academy Trust", code: 6) }

  # TODO: let!
  before do
    create(:support_organisation, :with_address,
           urn: "100253",
           name: "Specialist School for Testing",
           establishment_type: foundation,
           trust_code: "2314")

    create(:support_organisation, :with_address,
           urn: "100254",
           name: "Greendale Academy for Bright Sparks",
           phase: 7,
           number: "334",
           ukprn: "4346",
           establishment_type: community,
           trust_code: "2314")

    create(:support_establishment_group, :with_address,
           uid: "2314",
           name: "Testing Multi Academy Trust",
           establishment_group_type: mat)

    create(:support_establishment_group, :with_address,
           uid: "2315",
           name: "New Academy Trust",
           establishment_group_type: sat)
  end
end
