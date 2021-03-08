# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog 1.0.0].

## [Unreleased]

- specification templates are now sourced from the Contentful Category entry
- refactor how we find all journey answers into isolated service
- users are now told how they can resume a journey, and an address is provided for this
- robots.txt now excludes all journey and step pages
- steps/questions/tasks in the task lists are now grouped by Contentful Section entries
- start page now has revised copy with details on eligibility and what to expect
- The journey map is now clearer about what happens when you click a link
- The journey map now includes links to preview a step
- The journey map now displays markup to include a step's answer in the specification template
- users can answer questions which expect a number
- checkbox questions no longer alter the capitalisation of options
- fix ordering of section and step items
- users can answer questions which expect a currency
- questions can be hidden from view
- specification warning if there are incomplete tasks
- hidden questions can be shown through a new show_additional_question field for each question
- hidden questions can be rehidden again after changing the original answer
- hidden questions that were at one point answered, will be reshown with a change to an earlier question
- fix Redis connection errors on Heroku
- users can be asked extended checkbox questions which ask for further information
- markdown in help text fields is now parsed into HTML
- show and hide more than one additional question at a time
- users can be presenting with forking/branching question chains based on any one answer
- create an extended further information text box option for radio answers
- create extended further information text box option for checkbox answers
- radio questions can be configured with an "or" separator
- specification can show further information for radio answers
- specification can show further information for checkbox answers
- checkbox answers can be completed without choosing a given answer
- fix planning page link back to the service
- checkbox answers are not automatically joined by commas for the specification

## [release-005] - 2021-1-19

- users can see an initial slice of their specification as HTML at the end of their journey
- users can download their specification as a document in the .docx format
- checkbox answers are editable
- radio and select questions are created with the new `ExtendedOptions` field
- questions are now all loaded at the start of a journey, rather than step by step
- users start the journey at the task list instead of the first question
- check your answers pattern has been replaced by a task list
- radio questions can be configured to ask the user for additional text
- update the service name to the latest decision

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
- any user can see a start page for the specifying journey
- use GOV.UK Frontend framework
- users can see a basic form to start the specifying journey sourced by a
Contentful fixture
- specifying form is styled as a GOV.UK form
- validate that an answer is provided to a question
- the first specifying question comes directly from Contentful
- handle the exceptional case when a Contentful entry is missing
- multiple radio questions can be answered in sequence
- users can be asked to answer a short text question
- Contentful can redirect users to preview endpoints
- users can be asked to answer a long text question

[unreleased]: https://github.com/DFE-Digital/buy-for-your-school/compare/release-005...HEAD
[release-005]: https://github.com/DFE-Digital/buy-for-your-school/compare/release-004...release-005
[release-004]: https://github.com/DFE-Digital/buy-for-your-school/compare/release-003...release-004
[release-003]: https://github.com/DFE-Digital/buy-for-your-school/compare/release-002...release-003
[release-002]: https://github.com/DFE-Digital/buy-for-your-school/compare/release-001...release-002
[release-001]: https://github.com/DFE-Digital/buy-for-your-school/compare/release-000...release-001

[keep a changelog 1.0.0]: https://keepachangelog.com/en/1.0.0/
