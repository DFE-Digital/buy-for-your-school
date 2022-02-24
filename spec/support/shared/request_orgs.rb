RSpec.shared_context "with schools and groups" do
  let(:user) { create(:user, :many_supported_schools_and_groups) }
  let(:school_type) { create(:support_establishment_type, name: "Community school") }
  let(:sat) { create(:support_establishment_group_type, name: "Single-academy Trust") }
  let(:mat) { create(:support_establishment_group_type, name: "Multi-academy Trust") }

  before do
    create(:support_organisation, urn: "100253", name: "Specialist School for Testing")

    create(:support_organisation, :with_address,
           urn: "100254",
           name: "Greendale Academy for Bright Sparks",
           phase: 7,
           number: "334",
           ukprn: "4346",
           establishment_type: school_type)

    create(:support_establishment_group, :with_address,
           uid: "2314", name: "Testing Multi Academy Trust",
           establishment_group_type: mat)

    create(:support_establishment_group, :with_address,
           uid: "2315",
           name: "New Academy Trust",
           establishment_group_type: sat)
  end
end
