# 14. use-logit-for-application-logs

Date: 2021-04-19

## Status

![Accepted](https://img.shields.io/badge/adr-accepted-green)

## Context

- Application logs needs to be aggregated and presented back to the dev team to assist in monitoring and debugging of the live service.
- [DfE Digital have technical guidance expressing a preference for Logit](https://github.com/DFE-Digital/technical-guidance/blob/8380ad9dbfeefaeece081cace9f13e4c36200cd0/source/documentation/guides/default-technology-stack.html.md.erb#L93)
- We were prompted for a Logit account by DfE when setting up our GPaaS account
- GPaaS does provide access to logs but it is clumsy to access each environment over by using the CLI
- dxw have used other logging aggregators in the past such as Papertrail but as DfE have expressed a preference it makes sense to align our technical tooling

## Decision

Use Logit

## Consequences

- the logs DfE digital services are managed through a single application, owned and paid for by DfE. Transitioning from the contractor team to a DfE team should be easier
