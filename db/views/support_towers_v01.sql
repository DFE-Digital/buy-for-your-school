SELECT cases.id,
		CASE 
			WHEN cats.tower IN ('Business Services', 'Professional Services') THEN 'Services'
			WHEN cats.tower IN ('Catering', 'FM', 'Furniture') THEN 'FM and Catering'
			WHEN cats.tower = 'ICT' THEN 'ICT'
			WHEN cats.tower = 'Energy & Utilities' THEN 'Energy and Utilities'
			ELSE NULL
			END AS procops_tower,
		procs.stage,
		cases.state,
		cases.support_level
FROM support_cases AS cases
LEFT JOIN support_procurements AS procs ON procs.id = cases.procurement_id
LEFT JOIN support_categories AS cats ON cases.category_id = cats.id
WHERE cases.state IN (0, 1, 3) -- initial, opened and on hold