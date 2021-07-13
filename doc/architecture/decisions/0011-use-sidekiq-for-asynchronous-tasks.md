# 11. use sidekiq for asynchronous tasks

Date: 2020-11-30

## Status

![Accepted](https://img.shields.io/badge/adr-accepted-green)

## Context

We need a way for the service to automatically and regularly run a task.

We already have Redis available as our caching layer and Sidekiq works great with it.

An alternative could be to use Cron for scheduled tasks and a postgres backed asynchronous jobs, perhaps even run inline. We know how to get Sidekiq running with Docker and reusing Redis (rather than Postgres) for job data that is ephemeral feels a better fit given we already have Redis.

## Decision

Use Sidekiq for processing asynchronous tasks.

## Consequences

- We add another process/box of complexity to the system architecture though we would need to do this with Cron too
- It should take less time to add another asynchronous task in future
- It should take less time to add another scheduled task
- A clear separation of concerns between persistent data being in Postgres and ephemeral data in Redis
- Sidekiq can manage the scheduled task queue on initialiser which automatically takes care of provisioning jobs on all environments
- Adding Sidekiq takes more time now and will require another widget to Terraform when moving to GPaaS. We have done this before.
