describe "Case school details" do
  include_context "with an agent"

  let(:support_organisation) { create(:support_organisation, urn: "12345") }
  let(:support_case) { create(:support_case, :opened, organisation: support_organisation) }

  before do
    click_button "Agent Login"
    visit support_case_path(support_case)
  end

  it "displays a link open the school details from get information about school service in a new tab" do
    url = "https://www.get-information-schools.service.gov.uk/Establishments/Establishment/Details/12345"
    expect(page).to have_link_to_open_in_new_tab("View school information", href: url)
  end
end
