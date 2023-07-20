module Support::Case::Filterable
  extend ActiveSupport::Concern

  included do
    scope :by_agent, ->(agent_id) { where(agent_id:) }

    scope :by_state, ->(state) { state == "live" ? live : where(state:) }

    scope :live, -> { where(state: %w[initial opened on_hold]) }

    scope :by_category, ->(category_id) { where(category_id:) }

    scope :by_tower, ->(support_tower_id) { support_tower_id == "no-tower" ? without_tower : joins(:category).where(support_categories: { support_tower_id: }) }

    scope :without_tower, -> { joins("JOIN support_tower_cases stc ON stc.id = support_cases.id").where(stc: { tower_slug: "no-tower" }) }

    scope :by_stage, ->(stage) { joins(:procurement).where(procurement: { stage: }) }

    scope :by_level, ->(support_level) { where(support_level:) }

    scope :by_has_org, ->(has_org) { has_org ? where.not(organisation_id: nil) : where(organisation_id: nil) }

    scope :triage, -> { by_level([0, 1, 2]) }

    scope :high_level, -> { by_level([2, 3, 4]) }

    scope :created_by_e_and_o, -> { where(creation_source: :engagement_and_outreach_team) }
  end

  class_methods do
    def filtered_by(params)
      filtering_criteria = params.try(:filtering_criteria) || params

      valid_scopes_for_filtering(filtering_criteria).inject(all) do |scoped_query, (scope, criteria)|
        scoped_query.send(scope, criteria)
      end
    end

    def valid_scopes_for_filtering(filtering_criteria)
      filtering_criteria.each_with_object({}) do |(field, criteria), valid_scopes|
        potential_scope = "by_#{field}"

        next unless respond_to?(potential_scope)

        Array(criteria)
          .select { |criterion| criterion.present? || criterion == false }
          .each   { |criterion| valid_scopes[potential_scope] = criterion }
      end
    end
  end
end
