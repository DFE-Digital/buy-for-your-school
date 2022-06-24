SELECT
  sc.id AS case_id,
  sc.ref AS case_ref,
  sc.created_at AS created_at,
  GREATEST(sc.updated_at, si.created_at) AS last_modified_at,
  sc.source AS case_source,
  sc.state AS case_state,
  sc.closure_reason AS case_closure_reason,
  cat.title AS sub_category_title,
  sc.savings_actual AS savings_actual,
	sc.savings_actual_method AS savings_actual_method,
	sc.savings_estimate AS savings_estimate,
	sc.savings_estimate_method AS savings_estimate_method,
	sc.savings_status AS savings_status,
	sc.support_level AS case_support_level,
	sc.value AS case_value,
  se.name AS organisation_name,
  se.urn AS organisation_urn,
  se.ukprn AS organisation_ukprn,
  se.rsc_region AS organisation_rsc_region,
  se.local_authority_name AS organisation_local_authority_name,
  se.local_authority_code AS organisation_local_authority_code,
  se.uid AS organisation_uid,
  se.phase AS organisation_phase,
  se.organisation_status AS organisation_status,
  se.egroup_status AS establishment_group_status,
  se.establishment_type AS establishment_type,
  sf.name AS framework_name,
  sp.reason_for_route_to_market AS reason_for_route_to_market,
	sp.required_agreement_type AS required_agreement_type,
	sp.route_to_market AS route_to_market,
	sp.stage AS procurement_stage,
	sp.started_at AS procurement_started_at,
	sp.ended_at AS procurement_ended_at,
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
  ps.created_at AS participation_survey_date,
  es.created_at AS exit_survey_date,
  sir.referrer AS referrer				
FROM
  support_cases sc
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
  SELECT
  organisations.id,
  organisations.name,
  organisations.rsc_region,
  organisations.local_authority->>'name' as local_authority_name,
  organisations.local_authority->>'code' as local_authority_code,
  organisations.urn,
  organisations.ukprn,
  organisations.status as organisation_status,
  null as egroup_status,
  null as uid,
  organisations.phase,
  etypes.name as establishment_type,
  'Support::Organisation' as source
  FROM support_organisations organisations
  JOIN support_establishment_types etypes
    ON etypes.id = organisations.establishment_type_id
  UNION ALL
  SELECT
  egroups.id,
  egroups.name,
  null as rsc_region,
  null as local_authority_name,
  null as local_authority_code,
  null as urn,
  egroups.ukprn,
  null as organisation_status,
  egroups.status as egroup_status,
  egroups.uid,
  null as phase,
  egtypes.name as establishment_type,
  'Support::EstablishmentGroup' as source
  FROM support_establishment_groups egroups
  JOIN support_establishment_group_types egtypes
    ON egtypes.id = egroups.establishment_group_type_id
  ) AS se
ON sc.organisation_id = se.id AND sc.organisation_type = se.source
LEFT JOIN support_categories cat
  ON sc.category_id = cat.id
LEFT JOIN support_procurements sp
  ON sc.procurement_id = sp.id
LEFT JOIN support_frameworks sf
  ON sp.framework_id = sf.id
LEFT JOIN support_contracts ec
  ON sc.existing_contract_id = ec.id
LEFT JOIN support_contracts nc
  ON sc.existing_contract_id = nc.id
LEFT JOIN (
  SELECT si.created_at,
		 si.case_id
  FROM support_interactions si
  WHERE si.event_type = 3
  AND si.additional_data ->>'email_template' = 'fd89b69e-7ff9-4b73-b4c4-d8c1d7b93779'
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
  ) AS sir	
  ON si.case_id = sir.case_id;
