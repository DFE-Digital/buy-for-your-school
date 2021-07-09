# 10. use-redis-for-a-read-cache

Date: 2020-11-25

## Status

![Accepted](https://img.shields.io/badge/adr-accepted-green)

## Context

The service needs a way to build resilience against the external Contentful API becoming unexpectedly unavailable. This service is a single point of failure.

dxw use often use Rails and Redis together and recommend it as a technical choice.

## Decision

Add and use Redis for a read cache.

## Consequences

- if Contentful becomes unavailable disruption to our users should be mitigated
- another dependency exists within the infrastructure to manage
- we can more easily hook in Redis to be used as our session manager and other types of caching in future
