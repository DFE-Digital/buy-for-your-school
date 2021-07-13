# 12. Create infrastructure on GPaas Cloud Foundry with Terraform

Date: 2021-03-09

## Status

![Accepted](https://img.shields.io/badge/adr-accepted-green)

## Context

The early beta was originally hosted on dxw's Heroku to get delivering quickly whilst access to GPaaS could be set up.

Access to GPaaS with approved billing has now been confirmed so we are migrating the service to its longer term home.

## Decision

- Move the service from Heroku to GPaaS for all environments except the ephemeral pull request review environments.
- Use Terraform to define the infrastructure as code.


## Consequences

- the service will be easier to maintain in the long term if it is grouped with the rest of DfE's digital services inside GPaaS
- the service will need to be Terraformed as other DfE digital services
- as there are no real users of the service there is less risk to migrating the service now rather than later
- the pull request environments will no longer have strong parity with the live service on an infrastructure level. This can be changed in future if we have move time to also the approach taken by Teaching Vacancies
