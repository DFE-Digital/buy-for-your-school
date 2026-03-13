# 33. Use Rollbar for error monitoring

Date: 2026-03-13

## Status

![Accepted](https://img.shields.io/badge/adr-accepted-green)

## Context

We need a way to monitor application errors and get notified when something breaks in the app.

We evaluated the available options:

- **Sentry** — we were unable to get access to a Sentry account.

- **Azure Application Insights** — already available as part of our Azure hosting, but it does not provide the level of error monitoring detail we need. It is better suited to infrastructure-level monitoring than application-level error tracking

Rollbar provides clear, actionable error reports with full stack traces and context, making it straightforward to diagnose and fix issues. It also supports notifications via email and Microsoft Teams, which fits our existing team communication channels.

## Decision

Use Rollbar (free tier) for application error monitoring, with email and Microsoft Teams notifications configured to alert the team when errors occur.

## Consequences

- The team gets immediate visibility into application errors without having to trawl through logs or replicate issues on a console
- Email and Microsoft Teams notifications mean errors are surfaced in the channels the team already uses, reducing the risk of issues going unnoticed
- The free tier is sufficient for our current needs given the application's traffic levels
- If error volume grows significantly, we may need to revisit whether the free tier remains adequate
- Rollbar is an external dependency; if their service is unavailable, we lose their easy error visibility, however we still have access to Azure Application Insights and the full application logs.
