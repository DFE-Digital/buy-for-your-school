# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog 1.0.0].

## [unreleased]

- Microsoft Graph API library
- Synchronisation of emails from shared inbox into database

## [release-001] - 2021-12-xx

- initial models for case management functions
- unique 6 digit ref for cases starting with 000001
- resolve a case with notes
- imitate agent login using RBAC on the user model
- view an attached support request specification document
- re-categorise a case
- assign a case to an agent
- select a templated email
- write a non-templated email
- render emails using markdown
- send emails via Notify
- transactional activity logging for cases
- seed data from Get Information about Schools (GIAS) in CSV format
- background job to update GIAS records every month
- external link to school details in GIAS from case view
- CSV export for case management data
- create case service for case management
- create interaction for case management
- open case notes email preview in separate tab
- Javascript autocomplete field helper
- form to migrate a case from the hubs
