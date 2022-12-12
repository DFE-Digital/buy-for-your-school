# 31. Use CrawlerDetect to ignore bots when tracking user journeys

Date: 2022-11-04

## Status

Accepted

## Context

User journey tracking allows us to see how our service is used, but not all HTTP requests are made by humans. Requests made by bots and crawlers can compromise the accuracy of our data on service usage.

## Decision

Add the [CrawlerDetect](https://github.com/loadkpi/crawler_detect) gem as a dependency.

## Consequences

Requests made by bots can now be ignored.
