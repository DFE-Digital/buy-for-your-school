json.array! @cases do |case_search|
  # case
  json.id case_search.case_id
  json.ref case_search.case_ref

  # agent
  json.agent_name case_search.agent_name

  # organisation
  json.organisation_name case_search.organisation_name
  json.organisation_urn case_search.organisation_urn
  json.organisation_ukprn case_search.organisation_ukprn
end
