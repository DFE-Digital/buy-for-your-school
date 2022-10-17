module Support
  class CaseStatistics
    def live_cases = TowerCase.count
    def live_value = TowerCase.sum(:value)
    def new_cases = TowerCase.state_initial.count
    def on_hold_cases = TowerCase.state_on_hold.count
    def open_cases = TowerCase.state_opened.count

    def breakdown_of_stages_by_tower
      TowerCase.select(<<-SQL,
        tower_name AS name,
        tower_slug AS slug,
        tower_id,
        COUNT(id) AS live_cases,
        SUM(CASE WHEN state = 1 THEN 1 ELSE 0 END) AS open_cases,
        SUM(CASE WHEN state = 3 THEN 1 ELSE 0 END) AS on_hold_cases,
        SUM(CASE WHEN state = 0 THEN 1 ELSE 0 END) AS new_cases,
        SUM(COALESCE(value, 0.0)) AS live_value,
        '' as id
      SQL
                      )
      .group("tower_name, tower_slug, tower_id")
      .order(Arel.sql("(CASE WHEN tower_name = 'No Tower' THEN 9999 ELSE 0 END), tower_name ASC"))
    end

    def breakdown_of_levels_by_tower
      sql = <<-SQL
        SELECT
          support_tower_cases.tower_name AS name,
          support_tower_cases.tower_slug AS slug,
          SUM(CASE WHEN support_tower_cases.support_level = 0 THEN 1 ELSE 0 END) AS level_1_cases,
          SUM(CASE WHEN support_tower_cases.support_level = 1 THEN 1 ELSE 0 END) AS level_2_cases,
          SUM(CASE WHEN support_tower_cases.support_level = 2 THEN 1 ELSE 0 END) AS level_3_cases,
          SUM(CASE WHEN support_tower_cases.support_level = 3 THEN 1 ELSE 0 END) AS level_4_cases,
          SUM(CASE WHEN support_tower_cases.support_level = 4 THEN 1 ELSE 0 END) AS level_5_cases,
          SUM(COALESCE(support_tower_cases.value, 0.0)) AS live_value,
          '' as id
        FROM support_tower_cases
        GROUP BY
          support_tower_cases.tower_name,
          support_tower_cases.tower_slug
        ORDER BY
          (CASE WHEN support_tower_cases.tower_name = 'No Tower' THEN 9999 ELSE 0 END),
          support_tower_cases.tower_name ASC
      SQL

      TowerCase.find_by_sql(sql)
    end
  end
end
