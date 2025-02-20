# 16. Use rubocop-govuk for code linting

Date: 2021-06-23

## Status

![Accepted](https://img.shields.io/badge/adr-accepted-green)

Supersedes [3. Use Standard for Ruby linting](0003-use-standard-rb.md)

## Context

Gov.uk projects should maintain consistent [code formatting](https://gds-way.cloudapps.digital/manuals/programming-languages/ruby.html#code-formatting)

## Decision

Change from [Standard.rb](https://github.com/testdouble/standard), which is a wrapper around [Rubocop](),
to the [GovUK maintained version](https://github.com/alphagov/rubocop-govuk).

## Consequences

- Code consistency will continue to be maintained but will be inline with other government projects.
- Linting changes will be tackled gradually using:
  `rubocop --auto-gen-config --no-auto-gen-timestamp`