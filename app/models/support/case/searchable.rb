module Support::Case::Searchable
  extend ActiveSupport::Concern

  included do
    has_many :support_case_searches, class_name: "Support::CaseSearch"

    scope :by_search_term, ->(terms, exact_match: false) { joins(:support_case_searches).merge(Support::CaseSearch.find_a_case(terms, exact_match:)) }

    scope :by_mpan_or_mprn, lambda { |terms|
      where(id: joins(energy_onboarding_case: { onboarding_case_organisations: %i[gas_meters electricity_meters] })
        .where("energy_gas_meters.mprn = :terms OR energy_electricity_meters.mpan = :terms", terms:)
        .select("support_cases.id"))
    }
  end
end
