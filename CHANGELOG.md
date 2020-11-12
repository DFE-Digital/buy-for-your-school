# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog 1.0.0].

## [Unreleased]

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

[unreleased]: https://github.com/DfE/DFE-Digital/buy-for-your-school/compare/release-001...HEAD
[release-002]: https://github.com/DFE-Digital/buy-for-your-school/compare/release-001...release-002
[release-001]: https://github.com/DFE-Digital/buy-for-your-school/compare/release-000...release-001

[keep a changelog 1.0.0]: https://keepachangelog.com/en/1.0.0/
