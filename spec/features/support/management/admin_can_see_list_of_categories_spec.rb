require "rails_helper"

describe "Admin can see a list of Categories", bullet: :skip do
  include_context "with an agent", roles: %w[global_admin]

  before do
    define_categories(
      "ICT" => %w[Peripherals Laptops Websites],
      "Energy" => %w[Electricity Gas Water],
    )
  end

  scenario "Admin viewing category management page sees all categories listed" do
    visit support_management_categories_path

    expect(page).to have_content("ICT Peripherals")
    expect(page).to have_content("ICT Laptops")
    expect(page).to have_content("ICT Websites")
    expect(page).to have_content("Energy Electricity")
    expect(page).to have_content("Energy Gas")
    expect(page).to have_content("Energy Water")
  end
end
