SELECT
organisations.id,
organisations.name,
organisations.address->>'postcode' as postcode,
organisations.urn,
organisations.ukprn,
etypes.name as establishment_type,
'Support::Organisation' as source,
NULL as code
FROM support_organisations organisations
JOIN support_establishment_types etypes
  ON etypes.id = organisations.establishment_type_id
WHERE organisations.status != 2
UNION ALL
SELECT
egroups.id,
egroups.name,
egroups.address->>'postcode' as postcode,
null as urn,
egroups.ukprn,
egtypes.name as establishment_type,
'Support::EstablishmentGroup' as source,
NULL as code
FROM support_establishment_groups egroups
JOIN support_establishment_group_types egtypes
  ON egtypes.id = egroups.establishment_group_type_id
WHERE egroups.status != 2
UNION ALL
SELECT
local_authorities.id,
local_authorities.name,
NULL AS postcode,
NULL AS urn,
NULL AS ukprn,
'Local authority' AS establishment_type,
'LocalAuthority' as source,
local_authorities.la_code AS code
FROM local_authorities
