RSpec.feature "Supported Buying Proc-Ops Admin" do
  before do
    user_is_signed_in
    visit "/support/admin"
  end

  it do
    expect(page.title).to have_text "Supported Buying Admin"
  end
end
