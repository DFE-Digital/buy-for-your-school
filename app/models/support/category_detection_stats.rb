module Support
  class CategoryDetectionStats
    attr_reader :category_accuracy,
                :tower_accuracy,
                :attempted,
                :detected_cats,
                :unchanged_cats,
                :detected_towers,
                :unchanged_towers

    QUERY = <<-SQL.freeze
      SELECT
        base_stats.*,
        FLOOR((detected_cats / NULLIF(unchanged_cats, 0)) * 100) || '%' AS category_accuracy,
        FLOOR((detected_towers / NULLIF(unchanged_towers, 0)) * 100) || '%' AS tower_accuracy
      FROM (
        SELECT
          COUNT(*) AS attempted,
          COUNT(detected_cats.*) AS detected_cats,
          COUNT(unchanged_cats.*) AS unchanged_cats,
          COUNT(detected_towers.*) AS detected_towers,
          COUNT(unchanged_towers.*) AS unchanged_towers
        FROM support_interactions si
        JOIN support_cases sc ON sc.id = si.case_id
        LEFT JOIN support_categories detected_cats ON detected_cats.id = sc.detected_category_id
        LEFT JOIN support_categories unchanged_cats ON unchanged_cats.id = sc.category_id AND sc.category_id = sc.detected_category_id
        LEFT JOIN support_towers unchanged_towers ON unchanged_towers.id = unchanged_cats.support_tower_id
        LEFT JOIN support_towers detected_towers ON detected_towers.id = detected_cats.support_tower_id
        WHERE si.event_type = 8
        AND si.additional_data->>'detected_category_id' IS NOT NULL
      ) base_stats
    SQL

    def initialize(attributes = {})
      @category_accuracy = attributes["category_accuracy"]
      @tower_accuracy = attributes["tower_accuracy"]
      @attempted = attributes["attempted"]
      @detected_cats = attributes["detected_cats"]
      @unchanged_cats = attributes["unchanged_cats"]
      @detected_towers = attributes["detected_towers"]
      @unchanged_towers = attributes["unchanged_towers"]
    end

    def self.stats
      results = ActiveRecord::Base.connection.select_one(QUERY)
      new(results)
    end
  end
end
