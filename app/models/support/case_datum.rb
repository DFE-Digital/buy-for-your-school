require "csv"

module Support
  class CaseDatum < ApplicationRecord
    self.primary_key = :case_ref

    attribute :new_contract_duration, :interval
    attribute :previous_contract_duration, :interval

    # Since these are all coming from other records, there is a risk of method collision
    # To avoid this, prefixes are used
    enum case_state: Case.states, _prefix: :case
    enum case_source: Case.sources, _prefix: :case
    enum case_creation_source: Case.creation_sources, _prefix: :case
    enum case_closure_reason: Case.closure_reasons, _prefix: :reason
    enum organisation_phase: Organisation.phases, _prefix: :organisation
    enum organisation_status: Organisation.statuses, _prefix: :organisation
    enum establishment_group_status: EstablishmentGroup.statuses, _prefix: :establishment_group
    enum route_to_market: Procurement.route_to_markets, _prefix: :procurement
    enum reason_for_route_to_market: Procurement.reason_for_route_to_markets, _prefix: :procurement
    enum required_agreement_type: Procurement.required_agreement_types, _prefix: :procurement
    enum procurement_stage: Procurement.stages, _prefix: :procurement
    enum case_support_level: Case.support_levels, _prefix: :level

    def readonly?
      true
    end

    # @return [String]
    def self.to_csv
      CSV.generate(headers: true) do |csv|
        csv << column_names

        find_each { |record| csv << record.attributes.values }
      end
    end
  end
end
