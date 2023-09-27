require "rails_helper"

describe "Agent can update participating schools", js: true do
  include_context "with an agent"

  let(:organisation) { create(:support_establishment_group, uid: "123", establishment_group_type: create(:support_establishment_group_type, code: "6")) }
  let(:support_case) { create(:support_case, ref: "000001", agent:, organisation:) }

  before do
    create_list(:support_organisation, 3, trust_code: "123")

    visit support_case_path(support_case)
    click_link "School details"
    within("#school-details") do
      click_link "View"
      click_link "change"
      check "School #1"
      check "School #2"
      click_button "Save"
      sleep 0.2
    end
  end

  it "updates participating schools" do
    expect(support_case.participating_schools.pluck(:name)).to match_array(["School #1", "School #2"])
  end
end
