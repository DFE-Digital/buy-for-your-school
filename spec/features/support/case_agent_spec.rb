RSpec.feature "Case worker assignment" do
  include_context "with an agent"

  before do
    click_button "Agent Login"
    visit "/support/cases/#{support_case.id}/edit"
  end

  let(:support_case) { create(:support_case) }

  it "displays a title" do
    expect(find("h1.govuk-fieldset__heading")).to have_text "Assign to case worker"
  end

  it "lists agents by name" do
    expect(all("div.govuk-radios__item").count).to eq(1)
    expect(find("div.govuk-radios__item")).to have_text "Procurement Specialist"
  end

  it "displays the submit button" do
    expect(find_button("Assign")).to be_present
  end

  context "when assigning an agent to a case" do
    before do
      find("label.govuk-radios__label", text: "Procurement Specialist").click
      find_button("Assign").click
    end

    it "redirects to the case in question" do
      expect(page).to have_a_support_case_path
    end

    context "when on the case management dashboard" do
      before { visit "/support/cases#all-cases" }

      it "has an assigned agent" do
        expect(find("#all-cases tr.govuk-table__row", text: "St.Mary")).to have_text "Procurement Specialist"
      end

      it "has been opened" do
        expect(find("#all-cases tr.govuk-table__row", text: "St.Mary")).to have_text "Open"
      end
    end
  end
end
