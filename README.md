# Buy for your school

[![Maintainability](https://api.codeclimate.com/v1/badges/f119cce1678a8a67cca7/maintainability)](https://codeclimate.com/github/DFE-Digital/buy-for-your-school/maintainability)
![CI](https://github.com/DFE-Digital/buy-for-your-school/actions/workflows/continuous-integration.yml/badge.svg)
![Deploy](https://github.com/DFE-Digital/buy-for-your-school/actions/workflows/deploy.yml/badge.svg)

A service to help school buying professionals create tender documents that comply with the relevant government policy.
These tender documents can then be used to start a procurement process saving schools time and money.

## Documentation

Run `$ rake yard` to generate documentation for the project in `/documentation`

## Changelog

When making a change, update the [changelog](CHANGELOG.md) using the
[Keep a Changelog 1.0.0](https://keepachangelog.com/en/1.0.0/) format.
Pull requests should not be merged before any relevant updates are made.

## Architecture Decision Records

We use ADRs to document architectural decisions managed with [adr-tools](https://github.com/npryce/adr-tools).

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
