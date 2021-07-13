# 15. store-user-activity-in-app

Date: 2021-05-18

## Status

![Accepted](https://img.shields.io/badge/adr-accepted-green)

## Context

- We need to keep a record of activities taken by users so that we can gather quantitative research data
- We need to avoid third-party tracking services, since these carry with them privacy concerns, lack of clarity around retention rules, additional user consent, and the need for additional approvals

## Decision

Store all records of activities taken by users in-app.

## Consequences

- The storing of activity logs will introduce additional database overhead, both in terms of quantity of data and number of queries.
