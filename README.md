# Get Help Buying for Schools

[![Maintainability][codeclimate-badge]][codeclimate-report]
![CI][ci-badge]
![Deploy][deploy-badge]

A service to help school buying professionals create tender documents that comply with the relevant government policy.
These tender documents can then be used to start a procurement process saving schools time and money.

## Reusable Code

This project uses **[DfE Sign-In][dsi]** for authentication.
If your department project does the same, the code in `./lib/dsi` could help you.

## Documentation

Run `$ yardoc` to generate documentation for the project in `/documentation` and then `$ open ./documentation/index.html` to open in the browser.

## Changelog

When making a change, update the [changelog](CHANGELOG.md) using the
[Keep a Changelog 1.0.0][keep-a-changelog] format.

## Architecture Decision Records

We use ADRs to document architectural decisions managed with [adr-tools][adr].

## Access

| Environment |                              URL                              |
| :---------- | :-----------------------------------------------------------: |
| Development |                     http://localhost:3000                     |
| Research    | https://buy-for-your-school-research.london.cloudapps.digital |
| Staging     | https://staging-get-help-buying-for-schools.education.gov.uk  |
| Production  |     https://get-help-buying-for-schools.education.gov.uk      |



---

[adr]: https://github.com/npryce/adr-tools
[ci-badge]: https://github.com/DFE-Digital/buy-for-your-school/actions/workflows/continuous-integration.yml/badge.svg
[codeclimate-badge]: https://api.codeclimate.com/v1/badges/f119cce1678a8a67cca7/maintainability
[codeclimate-report]: https://codeclimate.com/github/DFE-Digital/buy-for-your-school/maintainability
[deploy-badge]: https://github.com/DFE-Digital/buy-for-your-school/actions/workflows/deploy.yml/badge.svg
[dsi]: https://services.signin.education.gov.uk/
[keep-a-changelog]: https://keepachangelog.com/en/1.0.0/
