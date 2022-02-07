SELECT
organisations.id,
organisations.name,
organisations.address->>'postcode' as postcode,
organisations.urn,
organisations.ukprn,
etypes.name as establishment_type,
'Organisation' as source
FROM support_organisations organisations
JOIN support_establishment_types etypes
  ON etypes.id = organisations.establishment_type_id
UNION ALL
SELECT
egroups.id,
egroups.name,
egroups.address->>'postcode' as postcode,
null as urn,
egroups.ukprn,
egtypes.name as establishment_type,
'EstablishmentGroup' as source
FROM support_establishment_groups egroups
JOIN support_establishment_group_types egtypes
  ON egtypes.id = egroups.establishment_group_type_id;
