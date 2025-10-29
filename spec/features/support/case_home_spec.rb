RSpec.feature "Case management dashboard", :js do
  before do
    visit support_root_path
  end

  it "does not show 'You must sign in' notification" do
    expect(page).not_to have_content "You must sign in"
  end
end
