# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog 1.0.0].

## [unreleased]

<!--

## [release-xxx] - xxxx-xx-xx

- value added [#ref](https://github.com/DFE-Digital/buy-for-your-school/commit/<hash>)
  or
- feature [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/<id>)

-->

- add feedback page to capture user feedback [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/885)
- add details page to capture user details after giving feedback [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/890)

## [release-020] - 2022-02-15
### "Find a Framework" support for trusts

- form steps reordered [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/866)
- add 'Is this the group or trust?' page [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/847)
- add trusts to DSI journey and update kick-out page [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/855)
- add school type to the CYA page [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/864)
- add group search page [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/850)
- add 'Is it a school or group?' page [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/849)
- make trust members eligible to access the service [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/863)

## [release-019] - 2022-01-31

- add redirect to case management at login for agents [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/803)

### Specify

- add users table download in JSON to /admin [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/831)

### "Find a Framework" support request feature

- FaF support start page [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/760)
- DSI or guest journey page [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/762)
- DSI entry [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/804)
- select your school page [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/778)
- search for a school page [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/811)
- confirm your school page [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/822)
- request message page [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/777)
- check your answers page [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/781)
- confirmation page [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/798)
- submit FaF request [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/806)
- [FIX] namespace validation errors [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/819)
- [FIX] support request tweaks [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/818)
- [FIX] feature tests reworking [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/817)
- [FIX] name and email pages formatting [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/815)
- [FIX] rename blank referrer [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/812)
- [FIX] testing branch [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/785)
- [FIX] QA review changes [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/827)
- [Fix] updated spec coverage [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/829)

## [release-018] - 2022-01-xx

- add role-based access control for data analysts to access `/admin` [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/729)
- add download link for user activity in CSV format for the `analyst` role [#ref](https://github.com/DFE-Digital/buy-for-your-school/pull/730)

## [release-017] - 2021-12-13

### Housekeeping

- refactor docker images to ensure only production dependencies are deployed
- refactor docker-compose to use chained override files
- remove unused dependencies from the original project template
- add JS testing capability to the suite and `chromedriver` to docker-compose
- add RSpec custom matchers for common path matching
- add RSpec custom matcher for breadcrumbs
- add RSpec custom matcher for links that open in a new tab
- add convenience task for CSV data export of activity log items

### Static Page Publishing

- convert committed pages to a database stored Page model
- publish and unpublish page content using Contentful via webhooks
- bypass the Redis cache for page actions for an immediate response
- retire `highvoltage` gem for static pages
- routing to custom pages controlled by content designers
- add breadcrumbs to custom pages controlled by content designers
- add optional sidebar to published pages
- add custom CSS to style body and sidebar content using markdown

### Content Design

- create a Contentful release strategy
- Contentful env `master` is now aliased to `staging` and `research` has been removed
- `production` points to Contentful `master` and `staging` points to Contentful `staging`
- delete Github action that destroys staging
- Github actions changed to clone `staging` to `develop` for local development (WIP)


## [release-016] - 2021-11-10

### House Keeping

- bump Ruby to version `3.0.1`
- document code using `yard`
- use `codeclimate` in CI pipeline to highlight areas of improvement
- change from `standardrb` to `rubocop-govuk` and convert lint style
- generate PDF format Entity Relationship Diagram with upon DB migrations
- add status badges to `README`
- use `pry` in the Rails console
- add additional developer tools to optional `Brewfile`
- validate and coerce data using `dry-schema` and `dry-transformer`
- add strict typing into new functional service objects using `dry-types`
- adopt `dry-validation` for complex form validations
- add `foreman` as an optional convenience in development
- remove unused `GetAllContentfulEntries` service object
- change route to destroy a session to be DELETE
- separate out concern for stale journeys and their removal `FlagStaleJourneysJob`,
  currently no-op until approved
- clean and fix deletion of stale journeys `DeleteStaleJourneysJob`, currently
  no-op until approved
- replace `htmltoword` and `redcarpet` with `pandoc` for parsing content in markdown
  and generating `.doc`, `pdf` and `.odt` files

### Dashboard Functionality

- add explicit ordering to the task model to allow continuing to the next unanswered task
- add extensible tally of counted steps to the task
- add state to `Journey` (initial, stale, archive or remove)
- drop `Journey.last_worked_on` in favour of `updated_at`
- allow user to (soft) delete a specification

### Question Functionality

- implement **interrupt pattern** which introduces a step that is not semantically
  a question but a statement which must be acknowledged rather than answered
- remove `staticContent` entity and add `Statement` entity in Contentful
- add custom answer validation logic using a range for number and date fields which
  can be controlled in Contentful
- fix progression to the next incomplete task
- add `skipped_ids` to `Task` to allow users to skip questions

### Content Design

Previously, unpublished questions could only be accessed via a dedicated environment
which used the main branch thereby preventing preview functionality in staging.

- a memoised client for both Contentful "delivery" and "preview" content in all environments
- `Content::Connector` instantiates both clients
- `Content::Client` is used internally as an interface to the Contentful ruby gem
- `CONTENTFUL_ACCESS_TOKEN` is replaced by `CONTENTFUL_DELIVERY_TOKEN` and `CONTENTFUL_PREVIEW_TOKEN`
- add `journey_maps#index` to allow content designers to switch category
- rename `journey_maps` to `design` to allow more intuitive URLs

### Categories

- remove references to `CONTENTFUL_DEFAULT_CATEGORY_ENTRY_ID`
- introduce `Category` model to mirror Contentful category entity
- add category `title` column to the dashboard
- add `categories#index` to enable users to create a specification from a chosen category
- update Contentful webhook handling to pick up updates to `Category` when they are published

### Authentication and Users

- expand DfE Sign-In scopes to gather names and email
- use env vars for DSI API `DFE_SIGN_IN_API_SECRET`, `DFE_SIGN_IN_API_ENDPOINT`
- add DfE Sign-In API to collect user organisations
- enable secure localhost DfE Sign-In authentication in development using SSL self-certs
- consolidate DfE Sign-In url generation logic controlled by `DSI_ENV`
- store identifying information for a `User`
- introduce a `Guest` entity using `dry-struct` to assist with RBAC
- replace `FindOrCreateUserfromSession` with `CreateUser` and `CurrentUser` functions
- display signed in user's name in header bar
- grant access to supported organisations and ProcOps users only

### ITHC

- explicitly set `X-Xss-Protection` header
- restrict all paths in `robots.txt`

### Requests for Support

- add multi-step form to request support
- add dynamic logic and validations to user input
- provide a better more accessible user experience using the form error summary
- send a confirmation email upon support request submission

### User Research

- link to external Qualtrics survey via `QUALTRICS_SURVEY_URL` env

### Accessibility

- add error summary component to forms
- customise presence validation message
- add breadcrumb navigation using `loaf`


---

## Diary Studies using the live environment

---

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

[unreleased]: https://github.com/DFE-Digital/buy-for-your-school/compare/release-017...HEAD
[release-017]: https://github.com/DFE-Digital/buy-for-your-school/compare/release-016...release-017
[release-016]: https://github.com/DFE-Digital/buy-for-your-school/compare/release-015...release-016
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
