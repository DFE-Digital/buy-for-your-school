RSpec.feature "Case management dashboard" do
  include_context "with an agent"

  before do
    create_list(:support_case, 3)
    visit support_root_path
  end

  it "is signed in as correct agent" do
    within ".govuk-header__container" do
      expect(page).to have_text "Signed in as Procurement Specialist"
    end
  end

  it "defaults to the 'my cases' tab" do
    expect(find("#my-cases")).not_to have_css ".govuk-tabs__panel--hidden"
  end

  context "when a case has actions required" do
    before do
      create(:support_case, :action_required, ref: "009999")
      visit "/support/cases"
    end

    it "displays the action flag" do
      within "#all-cases .case-list li", text: "009999" do
        expect(page).to have_css(".case-action-required-icon")
      end
    end
  end

  context "when my cases tab" do
    let!(:new_case) { create(:support_case, agent:) }

    before do
      create(:support_case, state: :resolved)
      visit "/support/cases"
    end

    it "shows my cases" do
      within "#my-cases" do
        expect(all(".case-list li").count).to eq(1)
        row = all(".case-list li")
        expect(row[0]).to have_text new_case.ref
      end
    end

    it "does not show resolved cases" do
      within "#my-cases" do
        within ".case-list ul" do
          expect(page).not_to have_text("Resolved")
        end
      end
    end
  end

  context "when new cases tab" do
    before do
      create(:support_case, state: :closed)
      visit "/support/cases"
    end

    it "shows new cases" do
      within "#new-cases" do
        expect(all(".case-list li").count).to eq(3)
      end
    end
  end

  context "when triage cases tab" do
    before do
      create(:support_case, state: :on_hold)
      visit "/support/cases"
    end

    it "shows triage cases" do
      within "#triage-cases" do
        expect(all(".case-list li").count).to eq(4)
      end
    end
  end

  context "when all cases tab" do
    before do
      create(:support_case, state: :resolved)
      create(:support_case, state: :closed)
      visit "/support/cases"
    end

    it "shows all valid cases" do
      within "#all-cases" do
        expect(all(".case-list li").count).to eq(4)
      end
    end

    it "does not show closed cases" do
      within "#all-cases" do
        within ".case-list ul" do
          expect(page).not_to have_text("Closed")
        end
      end
    end

    it "shows resolved cases" do
      within "#all-cases" do
        within ".case-list ul" do
          expect(page).to have_text("Resolved")
        end
      end
    end
  end
end
