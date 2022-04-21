RSpec.describe Support::CaseDatum, type: :model do
  describe "#to_csv" do
    it "includes headers" do
      expect(described_class.to_csv).to eql(
        "case_id,case_ref,created_at,last_modified_at,case_source,case_state,case_closure_reason,category_title,savings_actual,savings_actual_method,savings_estimate,savings_estimate_method,savings_status,organisation_name,organisation_urn,organisation_ukprn,organisation_rsc_region,organisation_local_authority_name,organisation_local_authority_code,organisation_uid,organisation_phase,organisation_status,establishment_group_status,establishment_type,framework_name,reason_for_route_to_market,required_agreement_type,route_to_market,procurement_stage,procurement_started_at,procurement_ended_at,previous_contract_started_at,previous_contract_ended_at,previous_contract_duration,previous_contract_spend,previous_contract_supplier,new_contract_started_at,new_contract_ended_at,new_contract_duration,new_contract_spend,new_contract_supplier,participation_survey_date,exit_survey_date\n",
      )
    end
  end
end
