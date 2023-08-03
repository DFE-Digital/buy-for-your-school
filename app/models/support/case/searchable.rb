module Support::Case::Searchable
  extend ActiveSupport::Concern

  included do
    has_many :support_case_searches, class_name: "Support::CaseSearch"

    scope :by_search_term, ->(terms) { joins(:support_case_searches).merge(Support::CaseSearch.find_a_case(terms)) }
  end
end
