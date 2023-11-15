SELECT
	scs.case_id AS id,
	scs.case_ref AS reference,
	scs.organisation_name AS organisation_name,
	scs.organisation_urn AS organisation_urn,
	scs.organisation_ukprn AS organisation_ukprn,
	NULL AS framework_name,
	NULL AS framework_provider,
	scs.agent_name AS agent_name,
	scs.agent_first_name AS agent_first_name,
	scs.agent_last_name AS agent_last_name,
	scs.created_at AS created_at,
	scs.updated_at AS updated_at,
	'Support::Case' AS source
FROM support_case_searches scs

UNION ALL

SELECT
	fe.id AS id,
	fe.reference AS reference,
	NULL AS organisation_name,
	NULL AS organisation_urn,
	NULL AS organisation_ukprn,
	ff.name AS framework_name,
	fp.short_name AS framework_provider,
	sa.first_name || ' ' || sa.last_name AS agent_name,
  sa.first_name AS agent_first_name,
  sa.last_name AS agent_last_name,
  fe.created_at AS created_at,
	fe.updated_at AS updated_at,
	'Frameworks::Evaluation' AS source
FROM frameworks_evaluations fe
LEFT JOIN frameworks_frameworks ff
	ON ff.id = fe.framework_id
LEFT JOIN frameworks_providers fp
	ON fp.id = ff.provider_id
LEFT JOIN support_agents sa
	ON sa.id = fe.assignee_id
