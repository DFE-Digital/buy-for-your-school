# 32. Remove Bullet gem

Date: 2024-12-15

## Status

![Accepted](https://img.shields.io/badge/adr-accepted-green)

Supersedes [ADR-0005](0005-use-bullet-to-catch-nplus1-queries.md)

## Context

Bullet was introduced in 2019 to catch N+1 queries during test runs. Over time:

- The gem was effectively disabled in `rails_helper.rb` (setting `Bullet.enable = false` before each test)
- A growing safelist of exceptions accumulated in `test.rb`
- Many specs were marked with `bullet: :skip` metadata (which wasn't actually wired to anything)

The gem was adding maintenance burden without providing value.

## Decision

Remove the Bullet gem and all associated configuration.

## Consequences

- Rely on production monitoring to identify N+1 queries in real usage patterns
- Remove maintenance burden of safelist entries and skipped specs
- Slightly faster gem loading in test environment
- N+1 queries introduced in development may not be caught until production monitoring flags them

