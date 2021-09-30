RSpec.feature "Case Management Dashboard - show" do
  let(:state) { "initial" }
  let(:support_case) { create(:support_case, state: state) }
  let(:base_url) { "/support/cases/#{support_case.id}" }


  before do
    user_is_signed_in
    visit base_url
  end

  it "has 3 visible tabs" do
    expect(all(".govuk-tabs__list-item", visible: true).count).to eq(3)
  end

  it "defaults to the 'School details' tab" do
    expect(find(".govuk-tabs__list-item--selected")).to have_text "School details"
  end

  describe "School details" do
    before { visit "#{base_url}#school-details" }

    it "shows School details section" do
      within "#school-details" do
        expect(find(".govuk-summary-list")).to be_visible
      end
    end

    it "School details section contain contact name" do
      within "#school-details" do
        expect(find(".govuk-summary-list")).to have_text "Contact name"
      end
    end
  end

  describe "Request details" do
    before { visit "#{base_url}#request-details" }

    it "lists request details" do
      within "#request-details" do
        expect(all(".govuk-summary-list__row")[0]).to have_text "Category"
        expect(all(".govuk-summary-list__row")[1]).to have_text "Description of problem"
        expect(all(".govuk-summary-list__row")[2]).to have_text "Attached specification"
      end
    end
  end

  describe "Case history" do
    before { visit "#{base_url}#case-history" }

    context "when currently assigned to a case owner" do
      before do
        agent = create(:support_agent)

        support_case.agent = agent
        support_case.save!

        # Refresh current page
        visit "#{base_url}#case-history"
      end

      it "shows a link to change case owner" do
        within "#case-history" do
          expect(find("p.govuk-body")).to have_text "Case owner: John Lennon"
        end
      end
    end

    it "does not show a link to change case owner" do
      within "#case-history" do
        expect(page).not_to have_selector("p.govuk-body")
      end
    end

    it "shows accordion" do
      within "#case-history" do
        expect(find(".govuk-accordion"))
          .to have_text "Phone"
      end
    end
  end

  it "shows the assign link" do
    expect(find("a.assign-owner")).to have_text "Assign to case worker"
  end

  it "shows the resolve link" do
    expect(find("a.resolve")).to have_text "Resolve case"
  end

  context "when the case is open" do
    let(:state) { "open" }

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
    let(:state) { "resolved" }

    it "shows the reopen case link" do
      expect(find("a.reopen")).to have_text "Reopen case"
    end
  end
end
