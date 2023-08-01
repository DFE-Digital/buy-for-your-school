module Support::Case::Filterable
  extend ActiveSupport::Concern

  included do
    scope :by_agent, ->(agent_ids) { by_filter(:agent_id, agent_ids) }

    scope :by_state, lambda { |states|
      states = Array(states)
      if states.include?("all")
        all
      else
        base = where(state: states.excluding("live", "all"))
        states.include?("live") ? base.merge(live) : base
      end
    }

    scope :live, -> { where(state: %w[initial opened on_hold]) }

    scope :by_category, ->(category_ids) { by_filter(:category_id, category_ids) }

    scope :by_tower, ->(support_tower_id) { support_tower_id == "no-tower" ? without_tower : joins(:category).where(support_categories: { support_tower_id: }) }

    scope :without_tower, -> { joins("JOIN support_tower_cases stc ON stc.id = support_cases.id").where(stc: { tower_slug: "no-tower" }) }

    scope :by_stage, ->(stage) { joins(:procurement).where(procurement: { stage: }) }

    scope :by_level, ->(support_levels) { by_filter(:support_level, support_levels) }

    scope :by_has_org, ->(has_org) { has_org ? where.not(organisation_id: nil) : where(organisation_id: nil) }

    scope :by_procurement_stage, ->(procurement_stage_ids) { by_filter(:procurement_stage_id, procurement_stage_ids) }

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
          .each   { |criterion| field.in?(%i[has_org search_term]) ? valid_scopes[potential_scope] = criterion : (valid_scopes[potential_scope] ||= []) << criterion }
      end
    end

    def by_filter(attribute, values)
      values = Array(values)

      if values.include?("all")
        all
      elsif values.include?("unspecified")
        where(attribute => nil)
      else
        where(attribute => values)
      end
    end
  end
end
