# 23. Use Scenic to manage database views

Date: 2022-02-15

## Status

Accepted

## Context

We have a need to use custom SQL views to aid in developing features such as searching.
As rspec loads the db schema from schema.rb it does not pick up on any database views, this breaks tests.

## Decision

Use scenic gem. Scenic gem manages versioning views and also ensures rspec can create the views for testing.

## Consequences

Creating and versioning database views becomes simple to manage.
