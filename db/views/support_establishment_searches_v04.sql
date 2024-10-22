SELECT
organisations.id,
organisations.name,
organisations.address->>'postcode' as postcode,
organisations.urn,
organisations.ukprn,
etypes.name as establishment_type,
'Support::Organisation' as source,
NULL as code,
organisations.status as organisation_status,
organisations.opened_date,
organisations.closed_date
FROM support_organisations organisations
JOIN support_establishment_types etypes
  ON etypes.id = organisations.establishment_type_id
WHERE organisations.status != 2
AND organisations.archived IS NOT TRUE
UNION ALL
SELECT
egroups.id,
egroups.name,
egroups.address->>'postcode' as postcode,
NULL as urn,
egroups.ukprn,
egtypes.name as establishment_type,
'Support::EstablishmentGroup' as source,
NULL as code,
NULL as organisation_status,
egroups.opened_date,
egroups.closed_date
FROM support_establishment_groups egroups
JOIN support_establishment_group_types egtypes
  ON egtypes.id = egroups.establishment_group_type_id
WHERE egroups.status != 2
AND egroups.archived IS NOT TRUE
UNION ALL
SELECT
local_authorities.id,
local_authorities.name,
NULL AS postcode,
NULL AS urn,
NULL AS ukprn,
'Local authority' AS establishment_type,
'LocalAuthority' as source,
local_authorities.la_code AS code,
NULL AS organisation_status,
NULL AS opened_date,
NULL AS closed_date
FROM local_authorities
WHERE local_authorities.archived IS NOT TRUE
ORDER BY organisation_status ASC