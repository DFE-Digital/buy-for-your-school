RSpec.feature "Filter cases", bullet: :skip do
  include_context "with an agent"

  let(:catering_cat) { create(:support_category, title: "Catering") }

  before do
    create_list(:support_case, 10)
    click_button "Agent Login"
  end
end
