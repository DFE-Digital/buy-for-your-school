RSpec.feature "Page with breadcrumbs" do
  before do
    create(:page, title: "Test Page 1", slug: "test-page-1")
    create(:page, title: "Test Page 2", slug: "test-page-2", breadcrumbs: ["Test Page 1,test-page-1", "Test Page 2,test-page-2"])
    visit "/test-page-2"
  end

  it "shows the breadcrumbs" do
    expect(page).to have_breadcrumbs ["Test Page 1", "Test Page 2"]
  end

  it "takes user to the right breadcrumb page" do
    click_link "Test Page 1"
    expect(page).to have_current_path "/test-page-1"
    expect(page).not_to have_breadcrumbs
  end
end
