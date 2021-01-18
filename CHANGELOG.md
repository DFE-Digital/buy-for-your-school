# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog 1.0.0].

## [Unreleased]

- users can see an initial slice of their specification as HTML at the end of their journey
- users can download their specification as a document in the .docx format
- checkbox answers are editable
- radio and select questions are created with the new `ExtendedOptions` field
- questions are now all loaded at the start of a journey, rather than step by step
- users start the journey at the task list instead of the first question
- check your answers pattern has been replaced by a task list
- radio questions can be configured to ask the user for additional text

## [release-004] - 2020-12-17

- fix primary key type on long_text_answers table to UUID
- nightly task to warm the Contentful cache for all entries
- form button content is configurable through Contentful
- users can be asked to provide a single date answer
- add Webmock to prevent real http requests in the test suite
- content users can see a journey map of all the Contentful steps
- users can be asked to provide multiple answers via a checkbox question
- journey map shows an error to the content team if a duplicate entry is detected
- journey map shows an error to the content team if the journey doesn't end within 50 steps
- refactor how we store and access a Step's associated Contentful Entry ID
- users can edit their answers
- only add Contentful entries that form part of a valid journey to the cache

## [release-003] - 2020-12-07

- add database foreign key constraints for better data integrity
- Contentful entry requests use a new Redis read cache
- service name included in the header
- refactor name of "Plan" to "Journey"
- refactor name of "Question" to "Step"
- refactor redis caching into reusable class
- users can be shown a step in the journey that is only static content

## [release-002] - 2020-11-16

- migrate answer database table into Radio and ShortText

## [release-001] - 2020-11-12

- address rails-template TODO
- any user can see a start page for the planning journey
- use GOV.UK Frontend framework
- users can see a basic form to start the planning journey sourced by a
Contentful fixture
- planning form is styled as a GOV.UK form
- validate that an answer is provided to a question
- the first planning question comes directly from Contentful
- handle the exceptional case when a Contentful entry is missing
- multiple radio questions can be answered in sequence
- users can be asked to answer a short text question
- Contentful can redirect users to preview endpoints
- users can be asked to answer a long text question

[unreleased]: https://github.com/DFE-Digital/buy-for-your-school/compare/release-004...HEAD
[release-004]: https://github.com/DFE-Digital/buy-for-your-school/compare/release-003...release-004
[release-003]: https://github.com/DFE-Digital/buy-for-your-school/compare/release-002...release-003
[release-002]: https://github.com/DFE-Digital/buy-for-your-school/compare/release-001...release-002
[release-001]: https://github.com/DFE-Digital/buy-for-your-school/compare/release-000...release-001

[keep a changelog 1.0.0]: https://keepachangelog.com/en/1.0.0/
