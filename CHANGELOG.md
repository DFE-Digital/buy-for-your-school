# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog 1.0.0].

## [Unreleased]

- fix primary key type on long_text_answers table to UUID
- nightly task to warm the Contentful cache for all entries

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

[unreleased]: https://github.com/DFE-Digital/buy-for-your-school/compare/release-003...HEAD
[release-003]: https://github.com/DFE-Digital/buy-for-your-school/compare/release-002...release-003
[release-002]: https://github.com/DFE-Digital/buy-for-your-school/compare/release-001...release-002
[release-001]: https://github.com/DFE-Digital/buy-for-your-school/compare/release-000...release-001

[keep a changelog 1.0.0]: https://keepachangelog.com/en/1.0.0/
