RSpec.feature "Supported Buying Proc-Ops Admin" do
  before do
    user_is_signed_in
    visit "/support/cases"
  end

  it 'shows main heading' do
    expect(find("govuk-heading-l")).to have_text "My cases"
  end
end