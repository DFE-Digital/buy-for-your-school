# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog 1.0.0].

## [Unreleased]

### Shared Unreleased

- added helper component to enable autocomplete functionality on fields

### Supported Unreleased

- add initial models for supported case management functions
- add unique 6 digit ref for cases starting with 000001
- add service to create SupportCases from SupportEnquiries
- add ability for agent to resolve a case with notes
- add ability for agent to send a non templated email on a case
- add ability for agent to send templated emails on a case
- add ability for agent to view specification
- privacy notice page
- accessibility page
- add link to school details in GIAS from case view
- add ability to re-categorise a case

### Specify Unreleased

**Infrastructure**

- Contentful env `master` is now aliased to `staging`
- Contentful env `research` has been removed
- `production` points to Contentful `master`
- `staging` points to Contentful `staging`
- Github actions changed to clone `staging` to `develop` for local development
- refactor docker tooling ensuring only production dependencies are deployed

**ITHC**

- explicitly set `X-Xss-Protection` header
- restrict all `robots.txt`

**Support Requests**

- add form to request support
- use `dry-validation` for complex form validations
- provide a better more accessible user experience using the form error summary
- send a confirmation email upon submission

**Rich Data**

- integrate fully with DSI to gather names, email and organisation at authentication
- add env vars for DSI API `DFE_SIGN_IN_API_SECRET`, `DFE_SIGN_IN_API_ENDPOINT`
- make a post authentication API call to DSI for roles and organisations information
- register localhost with DSI for callbacks in development
- document DSI changes including creation of SSL self-certs required in development
- integrate with GIAS by downloading and manipulating data in CSV format
- include capacity to export GIAS data as `YAML` or `JSON` for later use
- validate and coerce data using `dry-schema` and `dry-transformer`
- introduce a `Guest` entity using `dry-struct` to assist with RBAC
- replace `FindOrCreateUserfromSession` with `CreateUser` and `CurrentUser` functions
- add strict typing into new functional service objects using `dry-types`
- add `foreman` as an optional convenience in development
- store identifying information for a `User`
- display signed in user's name in header bar
- grant access to supported organisations and ProcOps users only

**House keeping**

- bump Ruby to version `3.0.1`
- document code using Yard
- use CodeClimate in CI pipeline to highlight areas of improvement
- change from `standardrb` to `rubocop-govuk` and convert lint style
- generate PDF format Entity Relationship Diagram with upon DB migrations
- add status badges to `README`
- use `pry` in the Rails console
- add additional developer tools to optional `Brewfile`
- remove unused `GetAllContentfulEntries` service object
- change route to destroy a session to be DELETE
- separate out concern for stale journeys and their removal `FlagStaleJourneysJob`,
  currently no-op until approved
- clean and fix deletion of stale journeys `DeleteStaleJourneysJob`, currently
  no-op until approved

**Steps**

- implement **interrupt pattern** which introduces a step that is not semantically
  a question but a statement
- remove `staticContent` entity and add `Statement` entity in Contentful (staging only)
- add custom answer validation logic which can be controlled in Contentful
- fix progression to the next incomplete task
- add `skipped_ids` to `Task` to allow users to skip questions
- add error summary component
- customise presence validation message
- provide qualtrics feedback (saved in QUALTRICS_SURVEY_URL env)

**Multiple Categories**

- remove references to `CONTENTFUL_DEFAULT_CATEGORY_ENTRY_ID`
- introduce `Category` model to mirror Contentful category entity
- add category `title` column to the dashboard
- add `journey_maps#index` to allow content designers to switch category
- add `categories#index` to enable users to create a specification from a chosen category
- rename `journey_maps` to `design` to allow more intuitive URLs
- WIP: data migration
- update Contentful webhook handling to pick up updates to `Category` when they are published

**Dashboard functionality**

- add explicit ordering to the task model to allow continuing to the next unanswered task
- add extensible tally of counted steps to the task
- add state to `Journey` (initial, stale, archive or remove)
- drop `Journey.last_worked_on` in favour of `updated_at`
- allow user to (soft) delete a specification

**Preview functionality**

- previously this depended upon a dedicated environment which used the main branch
  thereby preventing preview functionality in staging
- a memoised client for both Contentful delivery and preview is available for any environment
- `Content::Connector` instantiates both clients
- `Content::Client` is used internally as an interface to the Contentful ruby gem
- `APP_ENV_{ENV}_CONTENTFUL_ACCESS_TOKEN` is replaced by
  `APP_ENV_{ENV}_CONTENTFUL_DELIVERY_TOKEN` and `APP_ENV_{ENV}_CONTENTFUL_PREVIEW_TOKEN`

## Diary Studies using the live environment

## [release-015] - 2021-06-17

- always show task title even if it contains a single step
- replace journeys_path with a unified dashboard
- replace back to task list button with a link
- add button to continue completing the current task
- add button to continue to the next incomplete task if the current is complete
- track key user actions throughout the journey

## [release-014] - 2021-05-20

- remove now unused GetStepFromSection service to complete code migration to get steps from tasks
- answering steps in a task may take you to the next step unless you've answered them all
- tasks with no answers take the user straight to the first question instead of the task page
- swap task view pattern for the check your answers pattern

## [release-013] - 2021-05-18

- prevent random CI failures due to missing Redis connections
- GitHub action that allows manual cloning from master to staging with one-click for content testing
- steps are listed in the order set in Contentful rather than database insert order

## [release-012] - 2021-05-11

- sections are listed in the order set in Contentful rather than database insert order
- fix github secret limit by moving from repo secrets to environment secrets

## [release-011] - 2021-05-10

- error pages are styled
- document how to manage live environment variables
- Update all fixtures to include tasks
- Update the specs to work with the new task-enabled fixtures
- Remove `Journey#section_groups` and sever the direct Journey -> Steps association
- tasks now have their completion status indicated on the task list

## [release-010] - 2021-04-27

- add header and footer information for feedback and data requests
- force SSL in production to only accept HTTPS traffic, enable HSTS and secure tower cookies
- prevent concurrent sign ins
- Create Task model; fetch tasks from Contentful and create them in the
  database.
- Break direct association between Journey and Steps. Create new association
  between Tasks and Steps.
- Show Tasks on Journey page; clicking on a Task name takes you to a task page.
- Show Steps on Task page and allow users to answer questions from Task page
- fix CI not running RSpec
- existing specification page displays useful message when no specs exist
- fix text input field width to fit full screen width
- document where to find the service in the readme
- cache CI builds to reduce build times
- log information about contentful cache busting webhooks for debugging

## [release-009] - 2021-04-21

- fix multiple specification fields
- content security policy
- remove humans.txt

## [release-008] - 2021-04-19

- auto deploy research and preview environments

## [release-007] - 2021-04-19

- Add `noindex,nofollow` meta tag to all pages, as per Gov.UK guidance
- fix API auth by switching mechanism from Basic to Token
- remove `Returning to this specification` URL from task list
- Add Tasks to the database when iterating through Sections from Contentful
- fix XSS vulnerability by sanitising all user answers
- support specification templates that exceed 50,000 characters in Contentful

## [release-006] - 2021-04-01

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
- answer data is all available through the single `answer_x` convention, this has replaced `extended_answer_x` which has now been removed
- checkbox answers that are skipped can be identified in the specification
- fix branching so multiple rules can show the same question
- the specification lives on it's own page, separate to the task list
- fix checkbox questions where further information couldn't be saved for an option that included a special character
- further information for options that include special characters is now available to the specification
- incomplete specification documents include a warning within the document as well as the file name
- users return to the same place in the task list after answering a question
- fix extended radio questions so that further_information can be remembered when it can be provided through multiple fields
- flash messages can be shown in notification banners
- fix checkbox answer to save choices after previously skipping
- users can sign in using DfE Sign-in
- users can sign out using DfE Sign-in
- add new dashboard page with the ability to create new specifications
- users can only see their past journeys from the dashboard
- new API endpoint to allow Contentful to invalidate cached entries, allowing caching to stay on which prevents the app from being very slow/crashing on journey start
- automatically delete Journey and associated records if we deem it to have become stale, to reclaim the unused database rows

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

[unreleased]: https://github.com/DFE-Digital/buy-for-your-school/compare/release-015...HEAD
[release-015]: https://github.com/DFE-Digital/buy-for-your-school/compare/release-014...release-015
[release-014]: https://github.com/DFE-Digital/buy-for-your-school/compare/release-013...release-014
[release-013]: https://github.com/DFE-Digital/buy-for-your-school/compare/release-012...release-013
[release-012]: https://github.com/DFE-Digital/buy-for-your-school/compare/release-011...release-012
[release-011]: https://github.com/DFE-Digital/buy-for-your-school/compare/release-010...release-011
[release-010]: https://github.com/DFE-Digital/buy-for-your-school/compare/release-009...release-010
[release-009]: https://github.com/DFE-Digital/buy-for-your-school/compare/release-008...release-009
[release-008]: https://github.com/DFE-Digital/buy-for-your-school/compare/release-007...release-008
[release-007]: https://github.com/DFE-Digital/buy-for-your-school/compare/release-006...release-007
[release-006]: https://github.com/DFE-Digital/buy-for-your-school/compare/release-005...release-006
[release-005]: https://github.com/DFE-Digital/buy-for-your-school/compare/release-004...release-005
[release-004]: https://github.com/DFE-Digital/buy-for-your-school/compare/release-003...release-004
[release-003]: https://github.com/DFE-Digital/buy-for-your-school/compare/release-002...release-003
[release-002]: https://github.com/DFE-Digital/buy-for-your-school/compare/release-001...release-002
[release-001]: https://github.com/DFE-Digital/buy-for-your-school/compare/release-000...release-001
[keep a changelog 1.0.0]: https://keepachangelog.com/en/1.0.0/
