RSpec.feature "Case summary" do
  include_context "with an agent"

  before do
    click_button "Agent Login"
    visit "/support/cases/#{support_case.id}"
  end

  let(:support_case) { create(:support_case) }

  describe "Back link" do
    it_behaves_like "breadcrumb_back_link" do
      let(:url) { "/support/cases" }
    end
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
    before { visit "/support/cases/#{support_case.id}#request-details" }

    # TODO: add request details in next PR
    xit "lists request details" do
      within "#request-details" do
        expect(all(".govuk-summary-list__row")[0]).to have_text "Category"
        expect(all(".govuk-summary-list__row")[1]).to have_text "Description of problem"
        expect(all(".govuk-summary-list__row")[2]).to have_text "Attached specification"
      end
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
    it "shows the assign link" do
      expect(find("a.assign-owner")).to have_text "Assign to case worker"
      # TODO: asset links using the most appropriate matcher
      # expect(page).to have_link "Assign to case worker", href: "", class: "assign-owner"
    end

    it "shows the resolve link" do
      expect(find("a.resolve")).to have_text "Resolve case"
    end
  end

  context "when the case is open" do
    let(:support_case) { create(:support_case, state: "open") }

    it "shows the change owner link" do
      expect(find("a.change-owner")).to have_text "Change case owner"
    end

    it "shows the add note link" do
      expect(find("a.add-note")).to have_text "Add a case note"
    end

    it "shows the send email link" do
      expect(find("a.send-email")).to have_text "Send email"
    end

    it "show the log contact link" do
      expect(find("a.log-contact")).to have_text "Log contact with school"
    end
  end

  context "when the case is resolved" do
    let(:support_case) { create(:support_case, state: "resolved") }

    it "shows the reopen case link" do
      expect(find("a.reopen")).to have_text "Reopen case"
    end
  end
end
