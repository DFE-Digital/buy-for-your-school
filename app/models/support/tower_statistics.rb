module Support
  class TowerStatistics
    attr_reader :tower_slug

    def initialize(tower_slug:)
      @tower_slug = tower_slug
      @tower_overview = CaseStatistics.new.breakdown_of_stages_by_tower.find_by(tower_slug:)
    end

    def tower_id = @tower_overview.tower_id
    def name = @tower_overview.name
    def live_cases = @tower_overview.live_cases
    def live_value = @tower_overview.live_value
    def open_cases = @tower_overview.open_cases
    def on_hold_cases = @tower_overview.on_hold_cases
    def new_cases = @tower_overview.new_cases
    def missing_level_cases = TowerCase.where(tower_slug:, support_level: TowerCase::UNSPECIFIED_VALUE).count
    def missing_stage_cases = TowerCase.joins(:procurement).where(tower_slug:, procurement_stage_id: nil, procurement: { stage: nil }).count
    def missing_value_cases = TowerCase.where(tower_slug:, value: nil).count
    def missing_org_cases = TowerCase.where(tower_slug:, organisation_id: nil).count

    def breakdown_of_cases_by_stage
      sql = <<-SQL
        SELECT sub.procurement_stage_id, sub.procurement_stage_title, sub.open_cases, sub.on_hold_cases, sub.new_cases, sub.live_value, sub.id
        FROM (
          SELECT
            sps.id::text AS procurement_stage_id,
            sps.title AS procurement_stage_title,
            sps.stage AS procurement_stage_stage,
            sps.updated_at AS procurement_stage_updated_at,
            SUM(CASE WHEN stc.state = 1 THEN 1 ELSE 0 END) AS open_cases,
            SUM(CASE WHEN stc.state = 3 THEN 1 ELSE 0 END) AS on_hold_cases,
            SUM(CASE WHEN stc.state = 0 THEN 1 ELSE 0 END) AS new_cases,
            SUM(COALESCE(stc.value, 0.0)) AS live_value,
            '' AS id
          FROM support_tower_cases stc
          RIGHT JOIN support_procurement_stages sps
            ON stc.procurement_stage_id = sps.id::text
            AND stc.tower_slug = :tower_slug
          GROUP BY sps.id

          UNION

          SELECT
            'unspecified' AS procurement_stage_id,
            'Unspecified' AS procurement_stage_title,
            NULL AS procurement_stage_stage,
            NULL AS procurement_stage_updated_at,
            COALESCE(SUM(CASE WHEN stc.state = 1 THEN 1 ELSE 0 END), 0) AS open_cases,
            COALESCE(SUM(CASE WHEN stc.state = 3 THEN 1 ELSE 0 END), 0) AS on_hold_cases,
            COALESCE(SUM(CASE WHEN stc.state = 0 THEN 1 ELSE 0 END), 0) AS new_cases,
            COALESCE(SUM(stc.value), 0.0) AS live_value,
            '' AS id
          FROM support_tower_cases stc
          WHERE stc.procurement_stage_id IS NULL AND stc.tower_slug = :tower_slug
        ) AS sub
        ORDER BY sub.procurement_stage_stage, sub.procurement_stage_updated_at
      SQL

      TowerCase.find_by_sql([sql, { tower_slug: }])
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
