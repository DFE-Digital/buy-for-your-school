# 20. Use contentful for page content

Date: 2021-11-24

## Status

![Accepted](https://img.shields.io/badge/adr-accepted-green)

## Context

* Several content-only pages are served by our `Pages` table;
* `Pages` within the app mirror `Pages` within Contenful;
* This allows content designers (via Contentful) the ability to edit, add and
  delete Pages without help from developers.

## Decision

* Remove [high_voltage](https://github.com/thoughtbot/high_voltage);
* Rely on a final generic route that directs to `PagesController`;
* Use the slug to retrieve the Page from `t.pages`.

## Consequences

* It is possible for content designers to name a page slug that clashes with a
  route within the app;
* Rails will prioritise all other routing above this generic routing, so the
  issue will be apparent early on in testing/QA and easily fixed by renaming.
