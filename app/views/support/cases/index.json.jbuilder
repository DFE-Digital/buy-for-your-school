json.array! @cases do |kase|
  # case
  json.id kase.id
  json.ref kase.ref

  # agent
  json.agent_name "#{kase.agent&.first_name} #{kase.agent&.last_name}"

  # organisation
  json.organisation_name kase.organisation&.name
  json.organisation_urn kase.organisation&.urn
  json.organisation_ukprn kase.organisation&.ukprn
end
