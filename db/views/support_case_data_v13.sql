SELECT
  sc.id AS case_id,
  sc.ref AS case_ref,
  sc.created_at AS created_at,
  sc.created_at::DATE AS created_date,
  TO_CHAR(sc.created_at::DATE, 'yyyy') AS created_year,
  TO_CHAR(sc.created_at::DATE, 'mm') AS created_month,
  (CASE
    WHEN (DATE_PART('month', sc.created_at)) >= 4 THEN concat('FY', TO_CHAR(sc.created_at::DATE, 'yy'), '/', TO_CHAR((sc.created_at + interval '1 year')::DATE, 'yy'))
    WHEN (DATE_PART('month', sc.created_at)) < 4 THEN concat('FY', TO_CHAR((sc.created_at - interval '1 year')::DATE, 'yy'), '/', TO_CHAR(sc.created_at::DATE, 'yy'))
  END) as created_financial_year,
  GREATEST(sc.updated_at, si.created_at) AS last_modified_at,
  GREATEST(sc.updated_at, si.created_at)::DATE AS last_modified_date,
  TO_CHAR(GREATEST(sc.updated_at, si.created_at)::DATE, 'yyyy') AS last_modified_year,
  TO_CHAR(GREATEST(sc.updated_at, si.created_at)::DATE, 'mm') AS last_modified_month,
  rl.first_resolved_at::DATE as first_resolved_date,
  rl.last_resolved_at::DATE as last_resolved_date,
  sc.source AS case_source,
  sc.creation_source AS case_creation_source,
  sc.state AS case_state,
  sc.closure_reason AS case_closure_reason,
  cat.title AS sub_category_title,
  sc.other_category AS category_other,
  stc.tower_name AS tower_name,
  concat(sa.first_name, ' ', sa.last_name) AS agent_name,
  sc.savings_actual AS savings_actual,
  sc.savings_actual_method AS savings_actual_method,
  sc.savings_estimate AS savings_estimate,
  sc.savings_estimate_method AS savings_estimate_method,
  sc.savings_status AS savings_status,
  sc.support_level AS case_support_level,
  sc.value AS case_value,
  sc.with_school AS with_school_flag,
  sc.next_key_date AS next_key_date,
  sc.next_key_date_description AS next_key_date_description,
  sc.email AS organisation_contact_email,
  se.name AS organisation_name,
  se.urn AS organisation_urn,
  se.ukprn AS organisation_ukprn,
  se.rsc_region AS organisation_rsc_region,
  se.trust_name as parent_group_name,
  se.trust_code as parent_group_ukprn,
  se.local_authority_name AS organisation_local_authority_name,
  se.local_authority_code AS organisation_local_authority_code,
  se.gor_name AS gor_name,
  se.uid AS organisation_uid,
  se.phase AS organisation_phase,
  se.organisation_status AS organisation_status,
  se.egroup_status AS establishment_group_status,
  se.establishment_type AS establishment_type,
	ARRAY_LENGTH(fr.school_urns, 1) AS framework_request_num_schools,
	REPLACE(TRIM(fr.school_urns::TEXT, '{}"'),',',', ') AS framework_request_school_urns,
	ARRAY_LENGTH(cr.school_urns, 1) AS case_request_num_schools,
	REPLACE(TRIM(cr.school_urns::TEXT, '{}"'),',',', ') AS case_request_school_urns,
	JSONB_ARRAY_LENGTH(cps.participating_schools) AS case_num_participating_schools,
  REPLACE(TRIM(cps.participating_schools::TEXT, '[]'),'"','') as case_participating_school_urns,
  sf.name AS framework_name,
  sp.reason_for_route_to_market AS reason_for_route_to_market,
  sp.required_agreement_type AS required_agreement_type,
  sp.route_to_market AS route_to_market,
  sp.stage AS procurement_stage_old,
  sps.stage AS procurement_stage,
  sps.key AS procurement_stage_key,
  sp.started_at AS procurement_started_at,
  sp.ended_at AS procurement_ended_at,
  sp.e_portal_reference AS e_portal_reference,
  ec.started_at AS previous_contract_started_at,
  ec.ended_at AS previous_contract_ended_at,
  ec.duration as previous_contract_duration,
  ec.spend AS previous_contract_spend,
  ec.supplier AS previous_contract_supplier,
  nc.started_at AS new_contract_started_at,
  nc.ended_at AS new_contract_ended_at,
  nc.duration as new_contract_duration,
  nc.spend AS new_contract_spend,
  nc.supplier AS new_contract_supplier,
  nc.is_supplier_sme AS supplier_is_a_sme,
  ps.created_at AS participation_survey_date,
  es.created_at AS exit_survey_date,
  sir.referrer AS referrer
FROM
  support_cases sc
LEFT JOIN (
	SELECT
	sa.id,
	sa.first_name,
	sa.last_name
  FROM support_agents sa
) AS sa
ON sc.agent_id = sa.id
LEFT JOIN (
	SELECT
	stc.id,
	stc.procurement_id,
	stc.tower_name
  FROM support_tower_cases stc
) as stc
ON sc.procurement_id = stc.procurement_id

LEFT JOIN (select 
            log.support_case_id as case_id
            ,MIN(log.created_at) as first_resolved_at
            ,MAX(log.created_at) as last_resolved_at
            from public.support_activity_log_items as log
            WHERE log.action = 'resolve_case'

            group by log.support_case_id)

        AS rl
ON sc.id::VARCHAR = rl.case_id::VARCHAR

LEFT JOIN (
	SELECT
	fr.id,
	fr.support_case_id,
	fr.school_urns
  FROM framework_requests fr
) as fr
ON sc.id = fr.support_case_id
LEFT JOIN (
	SELECT
	cr.id,
	cr.support_case_id,
	cr.school_urns
  FROM case_requests cr
) as cr
ON sc.id = cr.support_case_id
LEFT JOIN (
	SELECT sco.support_case_id,
		jsonb_agg(so.urn) AS "participating_schools"
	FROM support_case_organisations AS sco 
	LEFT JOIN support_organisations AS so ON so.id = sco.support_organisation_id
	GROUP BY sco.support_case_id
) AS cps ON cps.support_case_id = sc.id
LEFT JOIN
  support_interactions si
ON si.id =
  (
    SELECT id
    FROM support_interactions i
    WHERE i.case_id = sc.id
    ORDER BY i.created_at ASC
    LIMIT 1
  )
LEFT JOIN (
  SELECT -- Support::Organisation cases
  organisations.id,
  organisations.name,
  organisations.rsc_region,
  local_authorities.name as local_authority_name,
  local_authorities.la_code as local_authority_code,
  organisations.gor_name as gor_name,
  organisations.urn,
  organisations.ukprn,
  parent.name as trust_name,
  parent.ukprn as trust_code,
  organisations.status as organisation_status,
  null as egroup_status,
  null as uid,
  organisations.phase,
  etypes.name as establishment_type,
  'Support::Organisation' as source
  FROM support_organisations organisations
  JOIN support_establishment_types etypes
    ON etypes.id = organisations.establishment_type_id
  JOIN local_authorities
    ON local_authorities.id = organisations.local_authority_id
  LEFT JOIN support_establishment_groups parent
      ON parent.uid = COALESCE(NULLIF(organisations.trust_code, ''), organisations.federation_code)
  UNION ALL
  
  SELECT -- Support::EstablishmentGroup cases
  egroups.id,
  egroups.name,
  null as rsc_region,
  null as local_authority_name,
  null as local_authority_code,
  null as gor_name,
  null as urn,
  egroups.ukprn,
  egroups.name as trust_name,
  egroups.ukprn as trust_code,
  null as organisation_status,
  egroups.status as egroup_status,
  egroups.uid,
  null as phase,
  egtypes.name as establishment_type,
  'Support::EstablishmentGroup' as source
  FROM support_establishment_groups egroups
  JOIN support_establishment_group_types egtypes
    ON egtypes.id = egroups.establishment_group_type_id
  UNION ALL
  
  SELECT -- LocalAuthority cases
  la.id,
  la.name,
  null as rsc_region,
  la.name as local_authority_name,
  la.la_code as local_authority_code,
  null as gor_name,
  null as urn,
  null as ukprn,
  null as trust_name,
  null as trust_code,
  null as organisation_status,
  null as egroup_status,
  null as uid,
  null as phase,
  'Local Authority' as establishment_type,
  'LocalAuthority' as source
  FROM local_authorities la
  ) AS se
ON sc.organisation_id = se.id AND sc.organisation_type = se.source
LEFT JOIN support_categories cat
  ON sc.category_id = cat.id
LEFT JOIN support_procurements sp
  ON sc.procurement_id = sp.id
LEFT JOIN support_procurement_stages sps
	ON sc.procurement_stage_id = sps.id
LEFT JOIN support_frameworks sf
  ON sp.framework_id = sf.id
LEFT JOIN support_contracts ec
  ON sc.existing_contract_id = ec.id
LEFT JOIN support_contracts nc
  ON sc.new_contract_id = nc.id
LEFT JOIN (
  SELECT si.created_at,
		 si.case_id
  FROM support_interactions si
  WHERE si.event_type = 3
  AND si.additional_data ->>'email_template' = 'fd89b69e-7ff9-4b73-b4c4-d8c1d7b93779'
  ORDER BY si.created_at ASC
  LIMIT 1
  ) AS ps	
  ON si.case_id = ps.case_id
LEFT JOIN (
  SELECT si.created_at,
		 si.case_id
  FROM support_interactions si
  WHERE si.event_type = 3
  AND si.additional_data ->>'email_template' = '134bc268-2c6b-4b74-b6f4-4a58e22d6c8b'
  ) AS es	
  ON si.case_id = es.case_id 
LEFT JOIN (
  SELECT si.additional_data ->>'referrer' AS referrer,
  		 si.case_id
  FROM support_interactions si
  WHERE si.event_type = 8
  ORDER BY si.created_at ASC
  LIMIT 1
  ) AS sir	
  ON si.case_id = sir.case_id;