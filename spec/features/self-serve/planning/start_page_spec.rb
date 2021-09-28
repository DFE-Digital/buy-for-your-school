RSpec.feature "Users can see a start page for planning their purchase" do
  scenario "Start page content is shown on the root path" do
    visit "/planning"

    expect(page).to have_content("Catering services")
    expect(page).to have_content("How to procure a catering contract for your school.")

    expect(page).to have_content("Before you start")
    page.find(:xpath, "//*[contains(text(),'Before you start')]").click
    expect(page).to have_content("A catering contract typically takes between 3 to 6 months to complete.")

    expect(page).to have_content("Ways to procure a catering contract")
    page.find(:xpath, "//*[contains(text(),'Ways to procure a catering contract')]").click
    expect(page).to have_content("A catering contract is a high value procurement. We generally say high is over 40,000.")

    expect(page).to have_content("Rules, regulations and requirements")
    page.find(:xpath, "//*[contains(text(),'Rules, regulations and requirements')]").click
    expect(page).to have_content("You'll need to be aware of some of the rules, regulations and requirements that can apply to a catering contract.")

    expect(page).to have_content("In-house catering")
    page.find(:xpath, "//*[contains(text(),'In-house catering')]").click
    expect(page).to have_content("Running the service in-house is another option. You may want to consider whether this is right for your school before you procure a contract. There are benefits and challenges to running the service yourself.")

    expect(page).to have_content("Starting a procurement process")
    page.find(:xpath, "//*[contains(text(),'Starting a procurement process')]").click
    expect(page).to have_content("Who to involve")

    expect(page).to have_content("Writing your requirements")
    page.find(:xpath, "//*[contains(text(),'Writing your requirements')]").click
    expect(page).to have_content("This is the document that you give to suppliers explaining what you want to buy, sometimes called a specification.")
    expect(page).to have_link("use our tool to create a specification", href: root_path)

    expect(page).to have_content("What to do next")
    page.find(:xpath, "//*[contains(text(),'What to do next')]").click
    expect(page).to have_content("Once you have your specification, you will need to decide if you will be using the open or restricted procedure.")

    expect(page).to have_content("Where to get help")
    expect(page).to have_content("See where to get help with buying for schools if you need it.")
    expect(page).to have_link("get help with buying for schools", href: "https://www.gov.uk/guidance/buying-for-schools/get-help-with-buying-for-schools")
  end

  scenario "the start page has the right content headers" do
    visit root_path
    expect(page).to have_xpath("//meta[@name=\"robots\" and contains(@content, \"noindex,nofollow\")]", visible: :hidden)
  end
end
