require "rails_helper"

describe "Updating case procurement details" do
  before { agent_is_signed_in }

  let(:support_case) { create(:support_case, :opened, procurement: support_procurement) }
  let(:support_procurement) { create(:support_procurement, :blank) }

  context "when there are no errors" do
    before do
      framework = create(:support_framework)

      patch support_case_procurement_details_path(support_case), params: {
        case_procurement_details_form: {
          required_agreement_type: "one_off",
          route_to_market: "direct_award",
          reason_for_route_to_market: "school_pref",
          framework_id: framework.id,
          "started_at(3i)" => "3",
          "started_at(2i)" => "12",
          "started_at(1i)" => "2020",
          "ended_at(3i)" => "2",
          "ended_at(2i)" => "12",
          "ended_at(1i)" => "2021",
        },
      }
    end

    it "redirects to case" do
      expect(response).to redirect_to("/support/cases/#{support_case.id}#case-details")
    end

    it "persists procurement details" do
      support_procurement.reload
      expect(support_procurement.required_agreement_type).to eq "one_off"
      expect(support_procurement.route_to_market).to eq "direct_award"
      expect(support_procurement.reason_for_route_to_market).to eq "school_pref"
      expect(support_procurement.framework.name).to match(/Test framework \d+/)
      expect(support_procurement.started_at).to eq Date.parse("2020-12-3")
      expect(support_procurement.ended_at).to eq Date.parse("2021-12-2")
    end
  end

  context "when dates fail validation due to the end date coming before the start date" do
    before do
      patch support_case_procurement_details_path(support_case), params: {
        case_procurement_details_form: {
          "started_at(3i)" => "3",
          "started_at(2i)" => "12",
          "started_at(1i)" => "2021",
          "ended_at(3i)" => "2",
          "ended_at(2i)" => "12",
          "ended_at(1i)" => "2020",
        },
      }
    end

    it "does not update the procurment" do
      expect(support_procurement).to eq(support_procurement.reload)
    end
  end
end
