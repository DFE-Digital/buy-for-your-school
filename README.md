# Buy for your school

[![Maintainability](https://api.codeclimate.com/v1/badges/f119cce1678a8a67cca7/maintainability)](https://codeclimate.com/github/DFE-Digital/buy-for-your-school/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/f119cce1678a8a67cca7/test_coverage)](https://codeclimate.com/github/DFE-Digital/buy-for-your-school/test_coverage)
![CI](https://github.com/DFE-Digital/buy-for-your-school/actions/workflows/continuous-integration.yml/badge.svg)
![Deploy](https://github.com/DFE-Digital/buy-for-your-school/actions/workflows/deploy.yml/badge.svg)

A service to help school buying professionals create tender documents that comply with the relevant government policy. These tender documents can then be used to start a procurement process saving schools time and money.

1. [Getting started](/doc/getting-started.md)
1. [Release process](/doc/release-process.md)
1. [Managing environment variables](/doc/managing-environment-variables.md)
1. [DfE Sign-in](/doc/dfe-sign-in.md)
1. [Console access](/doc/console-access.md)
1. [Logging](/doc/logging.md)
1. [Clean-up](/doc/clean-up.md)

## Making changes

When making a change, update the [changelog](CHANGELOG.md) using the
[Keep a Changelog 1.0.0](https://keepachangelog.com/en/1.0.0/) format. Pull
requests should not be merged before any relevant updates are made.

## Architecture decision records

We use ADRs to document architectural decisions that we make. They can be found
in doc/architecture/decisions and contributed to with the
[adr-tools](https://github.com/npryce/adr-tools).

## Access

| Environment    | URL                                                            |
| :------------- | :------------------------------------------------------------: |
|  Development   | http://localhost:3000                                          |
|  Research      | https://buy-for-your-school-research.london.cloudapps.digital  |
|  Preview       | https://buy-for-your-school-preview.london.cloudapps.digital   |
|  Staging       | https://staging-get-help-buying-for-schools.education.gov.uk   |
|  Production    | https://get-help-buying-for-schools.education.gov.uk           |

## Source

This repository was bootstrapped from
[dxw's `rails-template`](https://github.com/dxw/rails-template).
