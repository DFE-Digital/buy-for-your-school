# 34. Upgrade PostgreSQL to Latest Version

**Date:** 2026-03-16

## Status

![Accepted](https://img.shields.io/badge/adr-accepted-green)

## Context

Our platform currently runs on an older version of PostgreSQL that is approaching the end of its support lifecycle. Continuing to run an outdated database version increases operational risk due to:

* Lack of security updates
* Missing performance and stability improvements
* Reduced support from the open-source community
* Potential incompatibility with newer tools, libraries, and platform services

To maintain platform security, reliability, and long-term maintainability, we need to upgrade PostgreSQL to a supported and current version.

## Decision

### Development Environment

The development environment has been upgraded to **PostgreSQL 17** using the upgrade functionality provided by Azure.

* **Previous version:** PostgreSQL 13
* **Current version:** PostgreSQL 17

This allows the team to validate compatibility and ensure the application operates correctly on the latest version.

### Staging and Production Environments

The **staging and production environments are currently running PostgreSQL 13**.

These environments will be upgraded to **PostgreSQL 17** using **Terraform-managed infrastructure changes** once the new DevOps engineers join the team and can support the upgrade process.

## Consequences

### Positive

* Improved database performance and stability
* Continued security updates and long-term support
* Better compatibility with modern PostgreSQL features and tooling
* Reduced operational risk from running unsupported versions

### Risks / Considerations

* Potential breaking changes between PostgreSQL 13 and 17 must be reviewed and tested
* Database upgrade requires careful planning to minimise downtime
* Application compatibility has been successfully verified in the development environment after upgrading to PostgreSQL 17.
