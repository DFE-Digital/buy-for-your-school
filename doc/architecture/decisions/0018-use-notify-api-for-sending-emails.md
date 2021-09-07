# 18. Use Notify API for sending emails

Date: 2021-08-26

## Status

![Accepted](https://img.shields.io/badge/adr-accepted-green)

## Context

It is necessary for the service to confirm various actions with users via email messages.

## Decision

Gov.UK Notify is the recommended solution, using the `notifications-ruby-client` library.

## Consequences

- The option to also communicate via printed letter or SMS becomes available.
- No risks are introduced.
