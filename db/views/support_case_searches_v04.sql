SELECT
  sc.id AS case_id,
  sc.ref AS case_ref,
  sc.created_at AS created_at,
  sc.updated_at AS updated_at,
  sc.state AS case_state,
  sc.email AS case_email,
  ses.name AS organisation_name,
  ses.urn AS organisation_urn,
  ses.ukprn AS organisation_ukprn,
  sa.first_name || ' ' || sa.last_name AS agent_name,
  sa.first_name AS agent_first_name,
  sa.last_name AS agent_last_name,
  cat.title AS category_title
FROM
  support_cases sc
LEFT JOIN support_agents sa
  ON sa.id = sc.agent_id
LEFT JOIN support_establishment_searches ses
  ON sc.organisation_id = ses.id AND sc.organisation_type = ses.source
LEFT JOIN support_categories cat
    on sc.category_id = cat.id;
