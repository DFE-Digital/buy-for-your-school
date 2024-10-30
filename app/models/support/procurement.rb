# frozen_string_literal: true

module Support
  class Procurement < ApplicationRecord
    before_save :normalize_blank_values

    has_many :cases, class_name: "Support::Case", dependent: :nullify
    belongs_to :framework, class_name: "Support::Framework", optional: true
    belongs_to :register_framework, class_name: "Frameworks::Framework", foreign_key: "frameworks_framework_id", optional: true

    # Stage
    #
    #   need
    #   market_analysis
    #   sourcing_options
    #   go_to_market
    #   evaluation
    #   contract_award
    #   handover
    enum :stage, { need: 0, market_analysis: 1, sourcing_options: 2, go_to_market: 3, evaluation: 4, contract_award: 5, handover: 6 }

    # Required agreement type
    #
    #   one_off
    #   ongoing
    enum :required_agreement_type, { one_off: 0, ongoing: 1 }

    # Route to market
    #
    #   dfe_approved  - DfE Approved Deal / Framework
    #   bespoke       -  Bespoke Procurement
    #   direct_award  - Direct Award
    enum :route_to_market, { dfe_approved: 0, bespoke: 1, direct_award: 2 }

    # Reason for route to market
    #
    #   school_pref     - School Preference
    #   dfe_deal        - DfE Deal/Framework Selected
    #   no_dfe_deal     -  No DfE Deal/Framework Available
    #   better_than_dfe - Better Spec/Terms than DfE Deal
    enum :reason_for_route_to_market, { school_pref: 0, dfe_deal: 1, no_dfe_deal: 2, better_than_dfe: 3 }

    # Ensure blank strings are stored as nil
    def normalize_blank_values
      attributes.each_key do |column|
        self[column].present? || self[column] = nil
      end
    end
  end
end
