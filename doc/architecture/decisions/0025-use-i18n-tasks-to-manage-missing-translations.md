# 25. Use i18n-tasks to manage missing translations

Date: 2022-03-23

## Status

Accepted

## Context

Missing translations occasionally end up in production and unused translations remain, making the locales file more difficult to manage.

## Decision

Add the [i18n-tasks](https://github.com/glebm/i18n-tasks) gem as a development dependency.

## Consequences

The gem detects missing and unused translations, which will help us minimise these issues.
