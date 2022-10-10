module Support
  class TowerStatistics
    attr_reader :tower_slug

    def initialize(tower_slug:)
      @tower_slug = tower_slug
      @tower_overview = CaseStatistics.new.breakdown_of_stages_by_tower.find_by(tower_slug:)
    end

    def name = @tower_overview.name
    def live_cases = @tower_overview.live_cases
    def live_value = @tower_overview.live_value
    def open_cases = @tower_overview.open_cases
    def on_hold_cases = @tower_overview.on_hold_cases
    def new_cases = @tower_overview.new_cases
    def missing_level_cases = TowerCase.where(tower_slug:, support_level: TowerCase::UNSPECIFIED_VALUE).count
    def missing_stage_cases = TowerCase.where(tower_slug:, procurement_stage: TowerCase::UNSPECIFIED_VALUE).count
    def missing_value_cases = TowerCase.where(tower_slug:, value: nil).count

    def breakdown_of_cases_by_stage
      sql = <<-SQL
        SELECT
          procurement_stage.stage,
          SUM(CASE WHEN support_tower_cases.state = 1 THEN 1 ELSE 0 END) AS open_cases,
          SUM(CASE WHEN support_tower_cases.state = 3 THEN 1 ELSE 0 END) AS on_hold_cases,
          SUM(CASE WHEN support_tower_cases.state = 0 THEN 1 ELSE 0 END) AS new_cases,
          SUM(COALESCE(support_tower_cases.value, 0.0)) AS live_value,
          '' AS id
        FROM (
          SELECT * FROM GENERATE_SERIES(0, 6) AS stage
          UNION SELECT :unspecified AS stage
          ORDER BY stage
        ) procurement_stage
        LEFT JOIN support_tower_cases
          ON support_tower_cases.procurement_stage = procurement_stage.stage
          AND support_tower_cases.tower_slug = :tower_slug
        GROUP BY procurement_stage.stage
        ORDER BY procurement_stage.stage
      SQL

      TowerCase.find_by_sql([sql, { tower_slug:, unspecified: TowerCase::UNSPECIFIED_VALUE }])
    end

    def breakdown_of_cases_by_level
      sql = <<-SQL
        SELECT
          support_levels.support_level,
          SUM(CASE WHEN support_tower_cases.state = 1 THEN 1 ELSE 0 END) AS open_cases,
          SUM(CASE WHEN support_tower_cases.state = 3 THEN 1 ELSE 0 END) AS on_hold_cases,
          SUM(CASE WHEN support_tower_cases.state = 0 THEN 1 ELSE 0 END) AS new_cases,
          SUM(COALESCE(support_tower_cases.value, 0.0)) AS live_value,
          '' AS id
        FROM (
          SELECT * FROM GENERATE_SERIES(0, 4) AS support_level
          UNION SELECT :unspecified AS support_level
          ORDER BY support_level
        ) support_levels
        LEFT JOIN support_tower_cases
          ON support_tower_cases.support_level = support_levels.support_level
          AND support_tower_cases.tower_slug = :tower_slug
        GROUP BY support_levels.support_level
        ORDER BY support_levels.support_level
      SQL

      TowerCase.find_by_sql([sql, { tower_slug:, unspecified: TowerCase::UNSPECIFIED_VALUE }])
    end
  end
end
