require "rails_helper"

describe "Agent can view tower cases", bullet: :skip do
  include_context "with an agent"
  let!(:ict_tower)    { create(:support_tower, title: "ICT") }
  let!(:laptops)      { create(:support_category, title: "Laptops", tower: ict_tower) }
  let!(:laptops_case) { create(:support_case, ref: "123456", category: laptops) }
  let!(:media)        { create(:support_category, title: "Media", tower: ict_tower) }
  let!(:media_case)   { create(:support_case, ref: "987654", category: media) }
  let!(:energy_tower) { create(:support_tower, title: "Energy") }
  let!(:gas)          { create(:support_category, title: "Gas", tower: energy_tower) }
  let!(:gas_case)     { create(:support_case, ref: "888888", category: gas) }

  scenario "Agent viewing tower sees all cases in that tower" do
    Given :"I assigned to ICT tower"
    When :"I view my tower cases"
    Then :"I see all cases within the ICT tower only"
  end

protected

  def_Given :"I assigned to ICT tower" do
    click_button "Agent Login"
    agent.update!(support_tower: ict_tower)
    visit "/support"
  end

  def_When :"I view my tower cases" do
    click_on "View all cases in my tower"
  end

  def_Then :"I see all cases within the ICT tower only" do
    expect(page).to have_content("123456")
    expect(page).to have_content("987654")
    expect(page).not_to have_content("888888")
  end
end
