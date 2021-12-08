# 20. Use accessible-autocomplete for autocomplete fields

Date: 2021-11-29

## Status

![Accepted](https://img.shields.io/badge/adr-accepted-green)

## Context

It is necessary to provide autocomplete functionality to make certain fields quicker to enter by suggesting potential results to the user.

## Decision

We will use [accessible-autocomplete](https://github.com/alphagov/accessible-autocomplete) to provide the autocomplete capability in our pages.

This package has been chosen because accessibility has been carefully considered when developing the package.
Also it is designed to be used with `govuk` form styles so it will be in keeping with other form fields
and not be jarring to the user.

## Consequences

- No risks are introduced.
- A small additional increase in the assets payload, which should be mitigated by minification and caching.
- Future implementation of autocomplete functionality will be far simpler.
