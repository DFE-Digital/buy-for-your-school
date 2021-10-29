RSpec.feature "Case summary" do
  include_context "with an agent"

  before do
    click_button "Agent Login"
    # TODO: use case ref in the address path
    visit "/support/cases/#{support_case.id}"
  end

  let(:support_case) { create(:support_case, :with_documents) }

  describe "Back link" do
    it_behaves_like "breadcrumb_back_link" do
      let(:url) { "/support/cases" }
    end
  end

  it "shows the case reference heading" do
    expect(find("h3#case-ref")).to have_text "000001"
  end

  it "has 3 visible tabs" do
    expect(all(".govuk-tabs__list-item", visible: true).count).to eq(3)
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

  describe "Request details tab" do
    before { visit "/support/cases/#{support_case.id}#case-details" }

    # TODO: add request details in next PR
    xit "lists request details" do
      within "#case-details" do
        expect(all(".govuk-summary-list__row")[0]).to have_text "Category"
        expect(all(".govuk-summary-list__row")[1]).to have_text "Description of problem"
        expect(all(".govuk-summary-list__row")[2]).to have_text "Attached specification"
      end
    end

    it "lists specifications for viewing" do
      document = support_case.documents.first

      expect(page).to have_link "specification-1 (opens in new tab)", href: support_case_document_path(support_case, document)
    end
  end

  describe "Case history tab" do
    before { visit "/support/cases/#{support_case.id}#case-history" }

    context "when assigned to an agent" do
      let(:support_case) { create(:support_case, agent: agent) }

      it "shows a link to change case owner" do
        within "#case-history" do
          expect(find("p.govuk-body")).to have_text "Case owner: Procurement Specialist"
        end
      end
    end

    context "when not assigned to an agent" do
      it "does not show a link to change case owner" do
        within "#case-history" do
          expect(page).not_to have_selector("p.govuk-body")
        end
      end
    end
  end

  context "when the case is created" do
    it "has action links" do
      within "ul.govuk-list" do
        expect(page).to have_link "Assign to case worker", href: "/support/cases/#{support_case.id}/assignment/new", class: "govuk-link"
        expect(page).to have_link "Resolve case", href: "/support/cases/#{support_case.id}/resolution/new", class: "govuk-link"
      end
    end
  end

  context "when the case is open" do
    let(:support_case) { create(:support_case, state: "open") }

    it "has action links" do
      within "ul.govuk-list" do
        expect(page).to have_link "Change case owner", href: "/support/cases/#{support_case.id}/assignment/new", class: "govuk-link"
        expect(page).to have_link "Add a case note", href: "/support/cases/#{support_case.id}/interactions/new?option=note", class: "govuk-link"
        expect(page).to have_link "Send email", href: "/support/cases/#{support_case.id}/email/type/new", class: "govuk-link"
        expect(page).to have_link "Log contact with school", href: "/support/cases/#{support_case.id}/interactions/new?option=contact", class: "govuk-link"
      end
    end
  end

  context "when the case is resolved" do
    let(:support_case) { create(:support_case, state: "resolved") }

    it "has action links" do
      within "ul.govuk-list" do
        expect(page).to have_link "Reopen case", href: "#", class: "govuk-link"
      end
    end
  end
end
