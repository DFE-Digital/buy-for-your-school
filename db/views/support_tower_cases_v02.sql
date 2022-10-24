SELECT sc.id,
  sc.state,
  sc.value,
  sc.procurement_id,
  COALESCE(sp.stage, 99) AS procurement_stage,
  COALESCE(sc.support_level, 99) AS support_level,
  COALESCE(tow.title, 'No Tower') AS tower_name,
  LOWER(REPLACE(COALESCE(tow.title, 'No Tower'), ' ', '-')) AS tower_slug,
  tow.id AS tower_id,
  sc.created_at,
  sc.updated_at
FROM support_cases sc
JOIN support_procurements sp ON sp.id = sc.procurement_id
LEFT JOIN support_categories AS cat ON sc.category_id = cat.id
LEFT JOIN support_towers AS tow ON cat.support_tower_id = tow.id
WHERE sc.state IN (0, 1, 3) -- new, opened, on-hold
