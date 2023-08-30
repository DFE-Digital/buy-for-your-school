module Support::Case::Filterable
  extend ActiveSupport::Concern

  included do
    scope :by_agent, ->(agent_ids) { where(agent_id: agent_ids) }

    scope :by_state, lambda { |states|
      states = Array(states)
      states.include?("live") ? where(state: states.excluding("live")).or(live) : where(state: states)
    }

    scope :by_state_unspecified, -> { where(state: nil) }

    scope :live, -> { where(state: %w[initial opened on_hold]) }

    scope :by_category, ->(category_ids) { where(category_id: category_ids) }

    scope :by_category_unspecified, -> { where(category: nil) }

    scope :by_tower, ->(support_tower_id) { support_tower_id.include?("no-tower") ? without_tower : joins(:category).where(support_categories: { support_tower_id: }) }

    scope :without_tower, -> { joins("JOIN support_tower_cases stc ON stc.id = support_cases.id").where(stc: { tower_slug: "no-tower" }) }

    scope :by_stage, ->(stage) { joins(:procurement).where(procurement: { stage: }) }

    scope :by_level, ->(support_levels) { where(support_level: support_levels) }

    scope :by_level_unspecified, -> { where(support_level: nil) }

    scope :by_has_org, ->(has_org) { has_org ? where.not(organisation_id: nil) : where(organisation_id: nil) }

    scope :by_procurement_stage, ->(procurement_stage_ids) { where(procurement_stage_id: procurement_stage_ids) }

    scope :by_procurement_stage_unspecified, -> { where(procurement_stage_id: nil) }

    scope :by_legacy_stage_unspecified, -> { joins(:procurement).where(procurement: { stage: nil }) }

    scope :triage, -> { by_level([0, 1, 2]) }

    scope :high_level, -> { by_level([2, 3, 4]) }

    scope :created_by_e_and_o, -> { where(creation_source: :engagement_and_outreach_team) }
  end

  class_methods do
    def filtering(params = {})
      Support::Case::Filtering.new(scoped_cases: all, **params)
    end

    def filtered_by(params)
      filtering(params).results
    end
  end
end
