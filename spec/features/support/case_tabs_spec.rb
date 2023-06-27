RSpec.feature "Case summary" do
  include_context "with an agent"

  before do
    visit "/support/cases/#{support_case.id}"
  end

  let(:support_case) { create(:support_case, :with_documents, agent: nil) }

  describe "Back link" do
    it_behaves_like "breadcrumb_back_link" do
      let(:url) { "/support/cases" }
    end
  end

  it "shows the case reference heading" do
    expect(find("p#case-ref")).to have_text "000001"
  end

  it "has 6 visible tabs" do
    expect(all(".govuk-tabs__list-item", visible: true).count).to eq(6)
  end

  it "defaults to the 'School details' tab" do
    expect(find(".govuk-tabs__list-item--selected")).to have_text "School details"
  end

  describe "School details tab" do
    before { visit "/support/cases/#{support_case.id}#school-details" }

    it "primary contact name" do
      within "#school-details" do
        expect(find(".govuk-summary-list")).to have_text "Contact name"
      end
    end
  end

  describe "Case details tab" do
    before { visit "/support/cases/#{support_case.id}#case-details" }

    it "lists request details" do
      within "#case-details" do
        expect(all(".govuk-summary-list__row")[0]).to have_text "Source"
        expect(all(".govuk-summary-list__row")[1]).to have_text "Case level"
        expect(all(".govuk-summary-list__row")[2]).to have_text "Case value"
        expect(all(".govuk-summary-list__row")[3]).to have_text "Received"
        expect(all(".govuk-summary-list__row")[4]).to have_text "Sub-category"
        expect(all(".govuk-summary-list__row")[7]).to have_text "Procurement amount"
        expect(all(".govuk-summary-list__row")[8]).to have_text "Accessibility"
        expect(all(".govuk-summary-list__row")[9]).to have_text "Description of query"
        expect(all(".govuk-summary-list__row")[10]).to have_text "Attached specification"
      end
    end

    it "lists Procurement section headings details" do
      within "#case-details" do
        expect(find("#procurement-details-procurement")).to have_text "Procurement details"
        expect(find("#pd-existing-contract")).to have_text "Existing contract details"
        expect(find("#pd-new-contract")).to have_text "New contract details"
        expect(find("#pd-savings")).to have_text "Savings details"
      end
    end

    it "lists specifications for viewing" do
      document = support_case.documents.first

      expect(page).to have_link "specification-1 (opens in new tab)", href: support_case_document_path(support_case, document)
    end
  end

  context "when assigned to an agent" do
    let(:support_case) { create(:support_case, agent:) }

    it "shows a link to change case owner" do
      expect(page).to have_text "Case owner: Procurement Specialist"
    end
  end

  context "when the case is created" do
    it "has action links" do
      within "ul.govuk-list" do
        expect(page).to have_link "Assign to case worker", href: "/support/cases/#{support_case.id}/assignments/new", class: "govuk-link"
        expect(page).to have_link "Move emails to existing case", href: "/support/cases/#{support_case.id}/merge-emails/new", class: "govuk-link"
      end
    end
  end

  context "when the case is open" do
    let(:support_case) { create(:support_case, state: "opened") }

    it "has action links" do
      within "ul.govuk-list" do
        expect(page).to have_link "Change case owner", href: "/support/cases/#{support_case.id}/assignments/new", class: "govuk-link"
        expect(page).to have_link "Add a case note", href: "/support/cases/#{support_case.id}/interactions/new?option=note", class: "govuk-link"
        expect(page).to have_link "Log contact with school", href: "/support/cases/#{support_case.id}/interactions/new?option=contact", class: "govuk-link"
      end
    end
  end

  context "when the case is resolved" do
    let(:support_case) { create(:support_case, state: "resolved") }

    it "has action links" do
      within "ul.govuk-list" do
        expect(page).to have_link "Reopen case", href: "/support/cases/#{support_case.id}/opening", class: "govuk-link"
      end
    end
  end
end
