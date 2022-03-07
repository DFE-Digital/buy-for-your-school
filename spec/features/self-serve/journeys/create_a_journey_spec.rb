RSpec.feature "Creating a specification" do
  before do
    contentful_category = stub_contentful_category(fixture_filename: "#{fixture}.json")
    category = persist_category(contentful_category)
    user_exists_in_dfe_sign_in

    # landing page
    visit "/"
    # DfE sign in
    click_start
    # new journey
    click_create
    # choose category
    find("label", text: category.title).click
    # enter a name
    # begin
    click_continue
  end
end
