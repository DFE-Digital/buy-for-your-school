SELECT 	ff.id AS "framework_id",
		ff.source,
		ff.status,
		ff.name,
		ff.short_name,
		ff.url,
		ff.reference,
		fp.name AS "provider_name",
		fp.short_name AS "provider_short_name",
		fpc.name AS "provider_contact_name",
		fpc.email AS "provider_contact_email",
		ff.provider_start_date::DATE,
		ff.provider_end_date::DATE,
		ff.dfe_start_date::DATE,
		ff.dfe_review_date::DATE,
		ff.sct_framework_owner,
		ff.sct_framework_provider_lead,
		sap.first_name || ' ' || sap.last_name AS "procops_lead_name",
		sap.email AS "procops_lead_email",
		saeo.first_name || ' ' || saeo.last_name AS "e_and_o_lead_name",
		saeo.email AS "e_and_o_lead_email",
		ff.created_at::DATE,
		ff.updated_at::DATE,
		ff.dps,
		ff.lot,
		ff.provider_reference,
		ff.faf_added_date::DATE,
		ff.faf_end_date::DATE,
		cats.categories,
		(CASE 
			WHEN evals.has_evaluation IS NOT NULL THEN 'Yes'
			ELSE 'No'
			END) AS "has_evaluation",
		ff.contentful_id
FROM frameworks_frameworks AS ff
LEFT JOIN frameworks_providers AS fp ON ff.provider_id = fp.id
LEFT JOIN frameworks_provider_contacts AS fpc ON ff.provider_contact_id = fpc.id
LEFT JOIN support_agents AS sap ON ff.proc_ops_lead_id = sap.id
LEFT JOIN support_agents AS saeo ON ff.e_and_o_lead_id = saeo.id
LEFT JOIN (
			SELECT ffc.framework_id,
				jsonb_agg(sc.title) AS "categories"
			FROM frameworks_framework_categories AS ffc 
			LEFT JOIN support_categories AS sc ON sc.id = ffc.support_category_id
			GROUP BY ffc.framework_id
			) AS cats ON cats.framework_id = ff.id
LEFT JOIN (
			SELECT ffe.framework_id,
					COUNT(ffe.id) AS "has_evaluation"
			FROM frameworks_evaluations AS ffe 
			GROUP BY ffe.framework_id
			) AS evals ON evals.framework_id = ff.id