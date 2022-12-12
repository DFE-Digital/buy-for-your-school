# 27. Use Flipper to manage feature flags

Date: 2022-04-22

## Status

Accepted

## Context

Features that are dependent on other features often stay unreleased until the time is right. These feature branches can be difficult to maintain in meantime. Releasing these features when they are done and disabling them until the other dependencies are ready could make this easier.

## Decision

Add the [flipper](https://github.com/jnunemaker/flipper) gem as a dependency.

## Consequences

Features can be enabled or disabled in different environments based on readiness.
