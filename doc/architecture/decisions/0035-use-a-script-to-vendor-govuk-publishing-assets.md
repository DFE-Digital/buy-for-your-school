# 35. Use a script to vendor GOV.UK Publishing assets

Date: 2026-06-23

## Status

![Accepted](https://img.shields.io/badge/adr-accepted-green)

## Context

The application needs to reuse a small subset of assets from the `govuk_publishing_components` gem, primarily for the super navigation header and search UI.

Including the gem directly is a poor fit for this application because:

- the gem has an opinionated dependency tree;
- `govuk_app_config` introduces transitive OpenTelemetry dependencies that conflict with the rest of the application;
- the application already uses webpack and the existing Rails asset pipeline rather than the gem's full Rails-oriented packaging model;
- the header and search JavaScript do not align cleanly with the established Stimulus controller pattern in this codebase.

We also want a simple way to pin to a specific upstream gem version and refresh the copied assets when that version changes, without significantly changing the build or deployment process.

## Decision

Use a script to copy the required GOV.UK Publishing Components files into this repository instead of depending on the gem directly.

The script will:

- pin a specific upstream `govuk_publishing_components` version;
- copy the required stylesheet and image assets into `vendor/assets`;
- copy the minimal Ruby presenter helpers needed by the components into `lib/`;
- allow the JavaScript behaviour to be rewritten in this application using the existing Stimulus/controller conventions rather than copying the upstream JavaScript verbatim.

## Consequences

### Positive

- Reuses the upstream GOV.UK Publishing styles and images without vendoring the full gem
- Avoids the gem's transitive dependency tree, including the `govuk_app_config` OpenTelemetry dependencies
- Keeps the build and deployment process simple
- Makes the copied assets explicit and reviewable in this repository
- Allows the team to pin and update against a known upstream gem release
- Gives the application room to reimplement component behaviour in a way that fits the existing frontend stack

### Risks / Considerations

- The copied assets need to be refreshed manually when upstream changes are required
- There is still some maintenance overhead to keep the copied files aligned with the upstream gem version
- JavaScript behaviour that is rewritten locally may diverge from upstream behaviour if it is not kept under review
