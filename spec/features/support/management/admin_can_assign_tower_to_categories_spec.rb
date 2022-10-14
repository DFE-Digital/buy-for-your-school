require "rails_helper"

describe "Admin can assign a Tower to a Category" do
  include_context "with an agent"
  let!(:ict_tower)      { create(:support_tower, title: "ICT") }
  let!(:services_tower) { create(:support_tower, title: "Services") }
  let!(:ict)            { create(:support_category, title: "ICT") }
  let!(:laptops)        { create(:support_category, title: "Laptops", parent: ict, tower: ict_tower) }

  scenario "Admin assigns tower to Agent" do
    Given :"I am an admin"
    When :"I assign Services tower to Laptops Category"
    Then :"Laptops category now appears in the Services tower"
  end

  scenario "Non Admin is refused access to manage Categories" do
    Given :"I am not an admin"
    When :"I access the category management page"
    Then :"I am not able to manage categories"
  end

protected

  def_Given :"I am an admin" do
    user.update!(roles: %w[admin])
  end

  def_Given :"I am not an admin" do
    # dont assign admin role
  end

  def_When :"I assign Services tower to Laptops Category" do
    click_button "Agent Login"
    visit support_management_categories_path

    within "tr", text: "Laptops" do
      select "Services", from: "category[support_tower_id]"
      click_on "Save"
    end
  end

  def_When :"I access the category management page" do
    click_button "Agent Login"
    visit support_management_categories_path
  end

  def_Then :"Laptops category now appears in the Services tower" do
    expect(laptops.reload.tower).to eq(services_tower)
  end

  def_Then :"I am not able to manage categories" do
    expect(page).not_to have_content("Laptops")
    expect(page).to have_content("You do not have the required role to access this page")
  end
end
