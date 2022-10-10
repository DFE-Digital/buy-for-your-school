WITH category_towers AS (
  SELECT
    id,
    title,
    (
      CASE
      WHEN tower IN ('Business Services', 'Professional Services') THEN 'Services'
      WHEN tower IN ('Catering', 'FM', 'Furniture') THEN 'FM and Catering'
      WHEN tower IN ('ICT') THEN 'ICT'
      WHEN tower IN ('Energy & Utilities') THEN 'Energy and Utilities'
      ELSE 'No Tower'
      END
    ) AS tower_name
  FROM support_categories
)

SELECT sc.id,
  sc.state,
  sc.value,
  sc.procurement_id,
  COALESCE(sp.stage, 99) AS procurement_stage,
  COALESCE(sc.support_level, 99) AS support_level,
  COALESCE(cat.tower_name, 'No Tower') AS tower_name,
  LOWER(REPLACE(COALESCE(cat.tower_name, 'No Tower'), ' ', '-')) AS tower_slug,
  sc.created_at,
  sc.updated_at
FROM support_cases sc
JOIN support_procurements sp ON sp.id = sc.procurement_id
LEFT JOIN category_towers AS cat ON sc.category_id = cat.id
WHERE sc.state IN (0, 1, 3) -- new, opened, on-hold
