# 26. Use Semantic Logger to make logs more readable

Date: 2022-04-13

## Status

Accepted

## Context

Logs can be difficult to search and digest using the default Rails logger.

## Decision

Add the [rails_semantic_logger](https://logger.rocketjob.io/) gem as a dependency. This is the recommended approach when logging to Logit.io that is also used in Teacher Services as outlined [here](https://dfedigital.atlassian.net/wiki/spaces/BaT/pages/1936916523/Log+structure+guidelines) and [here](https://dfedigital.atlassian.net/wiki/spaces/BaT/pages/2045870109/Configuring+Rails+logger+for+GOVUK+PaaS).

## Consequences

Searching the logs in Logit.io becomes easier.
