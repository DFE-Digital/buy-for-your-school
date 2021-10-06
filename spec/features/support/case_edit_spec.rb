RSpec.feature "Case Management Dashboard - edit" do
  before do
    support_case = create(:support_case)

    user_is_signed_in
    visit "/support/cases/#{support_case.id}/edit"
  end

  it "displays a title" do
    expect(find("h1.govuk-fieldset__heading", visible: true)).to have_text "Assign to case worker"
  end

  it "lists agents by name" do
    expect(all("div.govuk-radios__item", visible: true).count).to eq(1)
    expect(find("div.govuk-radios__item")).to have_text "Joe Bloggs"
  end

  it "displays the submit button" do
    expect(find_button("Assign")).to be_present
  end

  context "when assigning agent to case" do
    before do
      find("label.govuk-radios__label", text: "Joe Bloggs").click
      find_button("Assign").click
    end

    it "redirects to the case in question" do
      expect(page).to have_a_support_case_path
    end

    context "when on the case management dashboard" do
      before { visit "/support/cases#all-cases" }

      specify "the case in question was in fact assigned to the agent" do
        expect(find("#all-cases tr.govuk-table__row", text: "St.Mary")).to have_text "Joe Bloggs"
      end

      specify "the case in question was opened" do
        expect(find("#all-cases tr.govuk-table__row", text: "St.Mary")).to have_text "OPEN"
      end
    end
  end
end
