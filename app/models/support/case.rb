# frozen_string_literal: true

require "csv"
require "pg_search"

module Support
  #
  # A case is opened from a "support enquiry" dealing with a "category of spend"
  #
  class Case < ApplicationRecord
    include EmailTicketable
    include EmailMovable
    include Filterable
    include StateChangeable
    include Sortable
    include Searchable
    include ActivityLoggable
    include Historyable
    include QuickEditable
    include Summarisable
    include SchoolPickable
    include Transferable
    include FileUploadable
    include Surveyable
    include Notifiable

    belongs_to :category, class_name: "Support::Category", optional: true
    belongs_to :query, class_name: "Support::Query", optional: true
    belongs_to :agent, class_name: "Support::Agent", optional: true
    belongs_to :organisation, polymorphic: true, optional: true

    has_many :exit_survey_responses, class_name: "ExitSurveyResponse"

    has_many :documents, class_name: "Support::Document", dependent: :destroy
    accepts_nested_attributes_for :documents, allow_destroy: true, reject_if: :all_blank

    has_many :case_attachments, class_name: "Support::CaseAttachment", foreign_key: :support_case_id

    has_one :hub_transition, class_name: "Support::HubTransition", dependent: :destroy

    belongs_to :created_by, class_name: "Support::Agent", optional: true

    belongs_to :existing_contract, class_name: "Support::ExistingContract", optional: true
    belongs_to :new_contract, class_name: "Support::NewContract", optional: true
    belongs_to :procurement, class_name: "Support::Procurement", optional: true

    has_many :energy_bills, class_name: "EnergyBill", foreign_key: :support_case_id

    has_many :case_organisations, class_name: "Support::CaseOrganisation", foreign_key: :support_case_id

    has_many :participating_schools, through: :case_organisations, source: :organisation

    belongs_to :detected_category, class_name: "Support::Category", optional: true

    belongs_to :procurement_stage, class_name: "Support::ProcurementStage", optional: true

    has_one :framework_request, class_name: "FrameworkRequest", foreign_key: :support_case_id
    has_one :case_request, class_name: "CaseRequest", foreign_key: :support_case_id

    accepts_nested_attributes_for :hub_transition, allow_destroy: true, reject_if: :all_blank

    # Support level
    #
    #   L1       - Advice and guidance only
    #   L2       - Pointing to a framework / catalogue
    #   L3       - Helping school run a framework but school doing system work
    #   L4       - Run framework on behalf of school
    #   L5       - Run bespoke procurement
    enum support_level: { L1: 0, L2: 1, L3: 2, L4: 3, L5: 4 }

    # Closure reason
    #
    #   resolved
    #   email_merge
    #   spam
    #   out_of_scope
    #   other
    enum closure_reason: { resolved: 0, email_merge: 1, spam: 2, out_of_scope: 3, other: 4, transfer: 5 }, _suffix: true

    # Source
    #
    #   digital         - specify cases
    #   nw_hub          - north west hub cases
    #   sw_hub          - south west hub cases
    #   incoming_email  -
    #   faf             - find a framework
    enum source: { digital: 0, nw_hub: 1, sw_hub: 2, incoming_email: 3, faf: 4, engagement_and_outreach: 5, schools_commercial_team: 6, engagement_and_outreach_cms: 7 }

    # Discovery Method
    #
    #   used_before         - I've used this service before
    #   meeting_or_event    - Meeting or event
    #   dfe_publication     - DfE publication (e.g. ESFA update, SBP update, Sector Bulletin)
    #   non_dfe_publication - Non-DfE newsletter
    #   recommendation      - Recommendation
    #   search_engine       - Search engine, such as Google
    #   social_media        - Social media, such as LinkedIn, Facebook, X (formerly Twitter)
    #   website             - Website, such as GOV.UK
    #   other               - Other
    enum discovery_method: { used_before: 0, meeting_or_event: 1, dfe_publication: 2, non_dfe_publication: 3, recommendation: 4, search_engine: 5, social_media: 6, website: 7, other: 8 }

    # Creation Source
    #
    #   default                 - created by a member of the ProcOps team
    #   engagement_and_outreach - created by a member of the E&O team
    enum creation_source: { default: 0, engagement_and_outreach_team: 5 }

    # Savings status
    #
    #   realised   - Realised
    #   potential  - Potential
    #   unrealised - Not realised
    enum savings_status: { realised: 0, potential: 1, unrealised: 2 }

    # Savings estimate method
    #
    #   previous_minus_cheapest  - [Previous spend] - [Cheapest quote]
    #   rrp_minus_cheapest       - [RRP] - [Cheapest quote]
    #   previous_minus_estimated - [Previous spend] - [Estimated Contract Value]
    #   rrp_minus_estimated      - [RRP] - [Estimated Contract Value]
    enum savings_estimate_method: { previous_minus_cheapest: 0, rrp_minus_cheapest: 1, previous_minus_estimated: 2, rrp_minus_estimated: 3 }

    # Savings actual method
    #
    #   previous_minus_award    - [Previous spend] - [Award Price ]
    #   alternative_minus_award - [Alternative received price] - [Award Price ]
    #   rrp_minus_award         - [RRP] - [Award Price ]
    enum savings_actual_method: { previous_minus_award: 0, alternative_minus_award: 1, rrp_minus_award: 2 }

    before_validation :generate_ref
    validates :ref, uniqueness: true, length: { is: 6 }, format: { with: /\A\d+\z/, message: "numbers only" }

    # @return [String]
    def self.to_csv
      CSV.generate(headers: true) do |csv|
        csv << column_names

        find_each { |record| csv << record.attributes.values }
      end
    end

    # Called before validation to assign 6 digit incremental number (from last case or the default 000000)
    # @return [String]
    def generate_ref
      return if ref.present?

      self.ref = (Support::Case.last&.ref || sprintf("%06d", 0)).next
    end

    # @return [Array, Support::Interaction]
    def support_request
      interactions&.support_request&.first
    end

    # If this case is associated with a MAT, there may be several participating_schools (including 0). Otherwise there should be 1 organisation.
    def schools
      organisation.is_a?(Support::Organisation) ? [organisation] : participating_schools
    end

    # The Local Education Authorities of the schools currently associated with the case, sorted alphabetically and with duplicates removed.
    # The 'if sch.respond_to?(:local_authority)' catches the edge case where a MAT is the organisation but none of its schools are selected.
    def leas
      leas = []
      schools.each { |sch| leas << sch.local_authority["name"] if sch.respond_to?(:local_authority) }
      leas.uniq.sort
    end

    def self.triage_levels
      %w[L1 L2 L3]
    end

    def request
      framework_request || case_request
    end

    def reference
      ref
    end

    def agent_name
      agent&.full_name || "UNASSIGNED"
    end

    def organisation_name
      organisation&.name
    end

    def sub_category
      category&.title || request&.category&.title
    end

    def assign_to_agent(agent, assigned_by: Current.agent)
      update!(agent:)
      agent.notify_assigned_to_case(support_case: self, assigned_by:)
    end
  end
end
