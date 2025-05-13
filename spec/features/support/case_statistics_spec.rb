RSpec.feature "Case statistics page" do
  # make agents
  let(:caseworker) { create(:support_agent, first_name: "ProcOps", last_name: "User", roles: %w[procops]) }
  let(:eo_member) { create(:support_agent, first_name: "E&O", last_name: "User", roles: %w[e_and_o]) }
  let(:alumni) { create(:support_agent, first_name: "Ex", last_name: "Caseworker", roles: %w[]) }

  # make towers
  let(:services_tower) { Support::Tower.find_by(title: "Services") }

  # make categories
  let(:category) { create(:support_category, title: "Books", tower: services_tower) }

  # make procurement sub-stages
  let(:substage_need) { create(:support_procurement_stage, key: "need", title: "Need", stage: "0") }
  let(:substage_stage_3_approval) { create(:support_procurement_stage, key: "stage_3_approval", title: "Stage 3 Approval", stage: "3") }

  before do
    # make cases
    # caseworker cases
    create(:support_case, state: "initial", support_level: "L1", procurement_stage: substage_need, category:, agent: caseworker)
    create(:support_case, state: "opened", support_level: "L2", procurement_stage: nil, category:, agent: caseworker)
    create(:support_case, state: "on_hold", support_level: "L3", procurement_stage: substage_stage_3_approval, category: nil, agent: caseworker)
    create(:support_case, state: "initial", support_level: "L4", procurement_stage: substage_need, category: nil, agent: caseworker)
    create(:support_case, state: "on_hold", support_level: "L5", procurement_stage: substage_need, category:, agent: caseworker)
    create(:support_case, state: "initial", support_level: nil, procurement_stage: substage_stage_3_approval, category:, agent: caseworker)
    create(:support_case, state: "resolved", support_level: "L5", procurement_stage: substage_need, category:, agent: caseworker)
    # former caseworker (now E&O) cases
    create(:support_case, state: "initial", support_level: "L1", procurement_stage: substage_need, category:, agent: eo_member)
    create(:support_case, state: "opened", support_level: "L2", procurement_stage: nil, category:, agent: eo_member)
    create(:support_case, state: "on_hold", support_level: "L3", procurement_stage: substage_stage_3_approval, category: nil, agent: eo_member)
    create(:support_case, state: "initial", support_level: "L4", procurement_stage: substage_need, category: nil, agent: eo_member)
    create(:support_case, state: "on_hold", support_level: "L5", procurement_stage: substage_need, category:, agent: eo_member)
    create(:support_case, state: "initial", support_level: nil, procurement_stage: substage_stage_3_approval, category:, agent: eo_member)
    create(:support_case, state: "resolved", support_level: "L5", procurement_stage: substage_need, category:, agent: eo_member)
    # former caseworker (left DfE) cases
    create(:support_case, state: "initial", support_level: "L1", procurement_stage: substage_need, category:, agent: alumni)
    create(:support_case, state: "opened", support_level: "L2", procurement_stage: nil, category:, agent: alumni)
    create(:support_case, state: "on_hold", support_level: "L3", procurement_stage: substage_stage_3_approval, category: nil, agent: alumni)
    create(:support_case, state: "initial", support_level: "L4", procurement_stage: substage_need, category: nil, agent: alumni)
    create(:support_case, state: "on_hold", support_level: "L5", procurement_stage: substage_need, category:, agent: alumni)
    create(:support_case, state: "initial", support_level: nil, procurement_stage: substage_stage_3_approval, category:, agent: alumni)
    create(:support_case, state: "resolved", support_level: "L5", procurement_stage: substage_need, category:, agent: alumni)
    # unassigned cases
    create(:support_case, state: "initial", support_level: "L1", procurement_stage: substage_need, category:, agent: nil)
    create(:support_case, state: "opened", support_level: "L2", procurement_stage: nil, category:, agent: nil)
    create(:support_case, state: "on_hold", support_level: "L3", procurement_stage: substage_stage_3_approval, category: nil, agent: nil)
    create(:support_case, state: "initial", support_level: "L4", procurement_stage: substage_need, category: nil, agent: nil)
    create(:support_case, state: "on_hold", support_level: "L5", procurement_stage: substage_need, category:, agent: nil)
    create(:support_case, state: "initial", support_level: nil, procurement_stage: substage_stage_3_approval, category:, agent: nil)
    create(:support_case, state: "resolved", support_level: "L5", procurement_stage: substage_need, category:, agent: nil)
  end

  context "when the user is an admin" do
    include_context "with an agent", roles: %w[global_admin]

    before do
      visit support_case_statistics_path
    end

    it "shows the headline statistics by live state" do
      within(".case-overview", text: "Live cases") { expect(page).to have_content("24") }
      within(".case-overview", text: "Open") { expect(page).to have_content("4") }
      within(".case-overview", text: "On hold") { expect(page).to have_content("8") }
      within(".case-overview", text: "New") { expect(page).to have_content("12") }
    end

    it "has 3 visible tabs" do
      expect(all(".govuk-tabs__list-item", visible: true).count).to eq(3)
    end

    it "defaults to the 'Overview by Person' tab" do
      expect(find(".govuk-tabs__list-item--selected")).to have_text "Overview by Person"
    end

    describe "shows Overview by Person tab" do
      it "containing Live cases by status table" do
        within "#stats-by-person" do
          expect(page).to have_text "Live cases by status"
          within ".overview-by-status" do
            within all(".govuk-table__row")[1] do
              expect(page).to have_text "ProcOps User"
              expect(all(".result-value")[0]).to have_text "6"
              expect(all(".result-value")[1]).to have_text "1"
              expect(all(".result-value")[2]).to have_text "2"
              expect(all(".result-value")[3]).to have_text "3"
            end
            within all(".govuk-table__row")[2] do
              expect(page).to have_text "FORMER STAFF"
              expect(all(".result-value")[0]).to have_text "12"
              expect(all(".result-value")[1]).to have_text "2"
              expect(all(".result-value")[2]).to have_text "4"
              expect(all(".result-value")[3]).to have_text "6"
            end
            within all(".govuk-table__row")[3] do
              expect(page).to have_text "UNASSIGNED"
              expect(all(".result-value")[0]).to have_text "6"
              expect(all(".result-value")[1]).to have_text "1"
              expect(all(".result-value")[2]).to have_text "2"
              expect(all(".result-value")[3]).to have_text "3"
            end
          end
        end
      end

      it "containing Live cases by level table" do
        within "#stats-by-person" do
          expect(page).to have_text "Live cases by level"
          within ".overview-by-level" do
            within all(".govuk-table__row")[1] do
              expect(page).to have_text "ProcOps User"
              expect(all(".result-value")[0]).to have_text "1"
              expect(all(".result-value")[1]).to have_text "1"
              expect(all(".result-value")[2]).to have_text "1"
              expect(all(".result-value")[3]).to have_text "1"
              expect(all(".result-value")[4]).to have_text "1"
              expect(all(".result-value")[5]).to have_text "0" # Level 6
              expect(all(".result-value")[6]).to have_text "0" # Level 7
              expect(all(".result-value")[7]).to have_text "1"
            end
            within all(".govuk-table__row")[2] do
              expect(page).to have_text "FORMER STAFF"
              expect(all(".result-value")[0]).to have_text "2"
              expect(all(".result-value")[1]).to have_text "2"
              expect(all(".result-value")[2]).to have_text "2"
              expect(all(".result-value")[3]).to have_text "2"
              expect(all(".result-value")[4]).to have_text "2"
              expect(all(".result-value")[5]).to have_text "0" # Level 6
              expect(all(".result-value")[6]).to have_text "0" # Level 7
              expect(all(".result-value")[7]).to have_text "2"
            end
            within all(".govuk-table__row")[3] do
              expect(page).to have_text "UNASSIGNED"
              expect(all(".result-value")[0]).to have_text "1"
              expect(all(".result-value")[1]).to have_text "1"
              expect(all(".result-value")[2]).to have_text "1"
              expect(all(".result-value")[3]).to have_text "1"
              expect(all(".result-value")[4]).to have_text "1"
              expect(all(".result-value")[5]).to have_text "0" # Level 6
              expect(all(".result-value")[6]).to have_text "0" # Level 7
              expect(all(".result-value")[7]).to have_text "1"
            end
          end
        end
      end
    end

    describe "shows Overview by Stage tab" do
      it "containing Live cases by top-level stage table" do
        within "#stats-by-stage" do
          expect(page).to have_text "Live cases by top-level stage"
          within ".overview-by-stage" do
            within all(".govuk-table__row")[0] do
              expect(all(".result-value")[0]).to have_text "0"
              expect(all(".result-value")[1]).to have_text "3"
              expect(all(".result-value")[2]).to have_text "Unspecified"
            end
            within all(".govuk-table__row")[1] do
              expect(page).to have_text "ProcOps User"
              expect(all(".result-value")[0]).to have_text "3"
              expect(all(".result-value")[1]).to have_text "2"
              expect(all(".result-value")[2]).to have_text "1"
            end
            within all(".govuk-table__row")[2] do
              expect(page).to have_text "FORMER STAFF"
              expect(all(".result-value")[0]).to have_text "6"
              expect(all(".result-value")[1]).to have_text "4"
              expect(all(".result-value")[2]).to have_text "2"
            end
            within all(".govuk-table__row")[3] do
              expect(page).to have_text "UNASSIGNED"
              expect(all(".result-value")[0]).to have_text "3"
              expect(all(".result-value")[1]).to have_text "2"
              expect(all(".result-value")[2]).to have_text "1"
            end
          end
        end
      end

      it "containing Live cases by substage for Stage 0" do
        within "#stats-by-stage" do
          expect(page).to have_text "Live cases by sub-stage for Stage 0"
          within ".overview-by-substage-for-stage-0" do
            within all(".govuk-table__row")[0] do
              expect(page).to have_text "Need"
            end
            within all(".govuk-table__row")[1] do
              expect(page).to have_text "ProcOps User"
              expect(all(".agent-name")[0]).to have_text "ProcOps User"
              expect(all(".result-value")[0]).to have_text "3"
            end
            within all(".govuk-table__row")[2] do
              expect(page).to have_text "FORMER STAFF"
              expect(all(".result-value")[0]).to have_text "6"
            end
            within all(".govuk-table__row")[3] do
              expect(page).to have_text "UNASSIGNED"
              expect(all(".result-value")[0]).to have_text "3"
            end
          end
        end
      end

      it "containing Live cases by substage for Stage 3" do
        within "#stats-by-stage" do
          expect(page).to have_text "Live cases by sub-stage for Stage 3"
          within ".overview-by-substage-for-stage-3" do
            within all(".govuk-table__row")[0] do
              expect(page).to have_text "Stage 3 Approval"
            end
            within all(".govuk-table__row")[1] do
              expect(page).to have_text "ProcOps User"
              expect(all(".agent-name")[0]).to have_text "ProcOps User"
              expect(all(".result-value")[0]).to have_text "2"
            end
            within all(".govuk-table__row")[2] do
              expect(page).to have_text "FORMER STAFF"
              expect(all(".result-value")[0]).to have_text "4"
            end
            within all(".govuk-table__row")[3] do
              expect(page).to have_text "UNASSIGNED"
              expect(all(".result-value")[0]).to have_text "2"
            end
          end
        end
      end
    end

    describe "shows Overview by Category tab" do
      it "containing Live cases by triage table" do
        within "#stats-by-category" do
          expect(page).to have_text "Live triage cases (levels 1 - 3)"
          within ".overview-by-triage" do
            within all(".govuk-table__row")[1] do
              expect(page).to have_text "ProcOps User"
              expect(all(".result-value")[0]).to have_text "1"
              expect(all(".result-value")[1]).to have_text "1"
              expect(all(".result-value")[2]).to have_text "1"
            end
            within all(".govuk-table__row")[2] do
              expect(page).to have_text "FORMER STAFF"
              expect(all(".result-value")[0]).to have_text "2"
              expect(all(".result-value")[1]).to have_text "2"
              expect(all(".result-value")[2]).to have_text "2"
            end
            within all(".govuk-table__row")[3] do
              expect(page).to have_text "UNASSIGNED"
              expect(all(".result-value")[0]).to have_text "1"
              expect(all(".result-value")[1]).to have_text "1"
              expect(all(".result-value")[2]).to have_text "1"
            end
          end
        end
      end

      it "containing Live cases by category table" do
        within "#stats-by-category" do
          expect(page).to have_text "Live category cases (levels 1 - 5)"
          within ".overview-by-category" do
            within all(".govuk-table__row")[0] do
              expect(all(".result-value")[0]).to have_text "Energy & Utilities"
              expect(all(".result-value")[1]).to have_text "FM & Catering"
              expect(all(".result-value")[2]).to have_text "ICT"
              expect(all(".result-value")[3]).to have_text "Services"
              expect(all(".result-value")[4]).to have_text "No Tower"
            end
            within all(".govuk-table__row")[1] do
              expect(page).to have_text "ProcOps User"
              expect(all(".result-value")[0]).to have_text "0"
              expect(all(".result-value")[1]).to have_text "0"
              expect(all(".result-value")[2]).to have_text "0"
              expect(all(".result-value")[3]).to have_text "4"
              expect(all(".result-value")[4]).to have_text "2"
            end
            within all(".govuk-table__row")[2] do
              expect(page).to have_text "FORMER STAFF"
              expect(all(".result-value")[0]).to have_text "0"
              expect(all(".result-value")[1]).to have_text "0"
              expect(all(".result-value")[2]).to have_text "0"
              expect(all(".result-value")[3]).to have_text "8"
              expect(all(".result-value")[4]).to have_text "4"
            end
            within all(".govuk-table__row")[3] do
              expect(page).to have_text "UNASSIGNED"
              expect(all(".result-value")[0]).to have_text "0"
              expect(all(".result-value")[1]).to have_text "0"
              expect(all(".result-value")[2]).to have_text "0"
              expect(all(".result-value")[3]).to have_text "4"
              expect(all(".result-value")[4]).to have_text "2"
            end
          end
        end
      end
    end

    describe "case statistics downloads" do
      it "has a link to download the CSV of the case data" do
        expect(page).to have_link "Download Cases CSV", class: "govuk-button", href: support_case_statistics_path(format: :csv)
      end

      it "provides a case data CSV download" do
        click_on "Download Cases CSV"
        expect(page.response_headers["Content-Type"]).to eq "text/csv"
        expect(page.response_headers["Content-Disposition"]).to match(/^attachment/)
        expect(page.response_headers["Content-Disposition"]).to match(/filename="case_data.csv"/)
      end
    end
  end
end
