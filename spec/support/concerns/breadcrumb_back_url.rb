shared_examples_for "breadcrumb_back_link" do
  it "has correct url in breadcrumb back link" do
    expect(page).to have_link "Back", href: url, class: "govuk-back-link"
  end
end
