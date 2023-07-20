module Support::Case::Sortable
  extend ActiveSupport::Concern

  included do
    scope :sort_by_action, lambda { |direction = "DESC"|
      order_sql = <<-SQL
        support_cases.action_required #{direction},
        CASE
          WHEN support_cases.state = #{states['initial']} THEN 10
          WHEN support_cases.state = #{states['opened']} THEN 9
          WHEN support_cases.state = #{states['on_hold']} THEN 8
          WHEN support_cases.state = #{states['resolved']} THEN 7
          ELSE 1
        END DESC,
        support_cases.ref DESC
      SQL

      order(Arel.sql(order_sql))
    }

    scope :sort_by_state, lambda { |direction = "DESC"|
      order_sql = <<-SQL
        CASE
          WHEN support_cases.state = #{states['initial']} THEN 10
          WHEN support_cases.state = #{states['opened']} THEN 9
          WHEN support_cases.state = #{states['on_hold']} THEN 8
          WHEN support_cases.state = #{states['resolved']} THEN 7
          ELSE 1
        END #{direction},
        support_cases.ref DESC
      SQL

      order(Arel.sql(order_sql))
    }

    scope :sort_by_last_updated, lambda { |direction = "ASC"|
      select_sql = <<-SQL
        support_cases.*,
        COALESCE((SELECT MAX(created_at) FROM support_interactions WHERE case_id = support_cases.id), support_cases.updated_at) AS last_updated_at
      SQL

      select(Arel.sql(select_sql)).order("last_updated_at #{direction}")
    }

    scope :sort_by_created, ->(direction = "ASC") { order("created_at #{direction}") }

    scope :sort_by_created_by, ->(direction = "ASC") { includes(:created_by).order("support_agents.first_name, support_agents.last_name #{direction}") }

    scope :sort_by_support_level, ->(direction = "ASC") { order("support_level #{direction}") }

    scope :sort_by_received, ->(direction = "ASC") { order("created_at #{direction}") }

    scope :sort_by_ref, ->(direction = "ASC") { order("ref #{direction}") }

    scope :sort_by_subcategory, ->(direction = "ASC") { includes(:category).order("support_categories.title #{direction}, support_cases.ref DESC") }

    scope :sort_by_agent, ->(direction = "ASC") { includes(:agent).order("support_agents.first_name #{direction}, support_agents.last_name #{direction}, support_cases.ref DESC") }

    scope :sort_by_organisation_name, lambda { |direction = "ASC"|
      join_sql = <<-SQL
        LEFT JOIN support_organisations ON support_cases.organisation_id = support_organisations.id AND support_cases.organisation_type = \'#{Support::Organisation.name}\'
        LEFT JOIN support_establishment_groups ON support_cases.organisation_id = support_establishment_groups.id AND support_cases.organisation_type = \'#{Support::EstablishmentGroup.name}\'
      SQL

      order_sql = <<-SQL
        COALESCE(support_organisations.name, support_establishment_groups.name) #{direction}, support_cases.ref DESC
      SQL

      joins(Arel.sql(join_sql)).order(Arel.sql(order_sql))
    }

    scope :sort_by_value, ->(direction = "ASC") { order("value #{direction}") }
  end

  class_methods do
    def sorted_by(sorting_params)
      field, direction = sorting_params.first

      public_send("sort_by_#{field}", direction == "descending" ? "DESC" : "ASC")
    end
  end
end
