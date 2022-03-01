# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog 1.0.0].

## [unreleased]

- Agent can update the problem description on a case [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/899)
- Agent can save email attachments to a case [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/896)
- Agent can reopen, close and place a case on-hold, while incoming emails on closed cases create a new case, and reopens resolved cases. Agent can also track the time a state transition occurred [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/887)

<!--

## [release-xxx] - xxxx-xx-xx

- value added [#ref](https://github.com/DFE-Digital/buy-for-your-school/commit/<hash>)
  or
- feature [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/<id>)

-->

## [release-004] - 2022-02-15 (020)

- add ability to close a new case created by an inbound email [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/897)
- Case can be set to an organisation or group, with search box to search both organisations and groups [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/851)
- Add pagination [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/854)
- Ability to merge a NEW email case into an existing case [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/853)
- On Create a case, allow Category to be 'undefined' [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/848)
- Remove actions for closed cases. [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/881)

## [release-003] - 2022-01-31 (019)

**Fixes**

- Add salutation and signature to "non-templated" email preview [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/802)
- Retain edited email body when going back from preview [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/791)
- Category and school name not being displayed [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/797)
- Only display case source if known [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/755)
- Malformed link to read email [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/708)
- Error on phone number validation [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/767)
- Keep agent assigned when resolving a case [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/788)
- Calculate dates for procurement contracts [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/790)

**Features**

- Case worker can view email attachments within CM
- Seed establishment group data from GIAS [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/816)
- Add attachments to email from MSGraph [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/770)
- "Find a Framework" support request case creation [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/806)
- Update support request additional data (interaction) styling [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/691)
- Add ability to persist procurement, contract and savings data on cases [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/704)
- CM Incoming emails integration [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/725)
- Case worker can see a list of emails separately to the cases [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/725)
- Case worker sees ACTION status when new email arrives for case [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/782)
- CW can acknowledge an email notification so that indicator is cleared [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/787)
- Allow the Organisation (optional) for a case to be updated [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/801)
- Auto create (no case ref) a case from an inbound email [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/805)
- Optional Contact name on create a case screen [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/809)

## [release-002] - 2022-01-xx (018)

- Microsoft Graph API library [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/694)
- Synchronisation of emails from shared inbox into database [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/725)
- Emails listed within case management outside of cases [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/725)
- Emails listed within case history [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/725)
- Procurement details tab [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/704)

## [release-001] - 2021-12-13 (017)

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
