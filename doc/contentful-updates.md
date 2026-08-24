# Contentful Updates

As content and content models change in Contentful, those changes need to be promoted across environments in a controlled way. This document sets out the expected workflow for schema changes and content changes.

## General

New fields and significant content model changes should be planned with developer input so the application is ready to handle them.

Use environments with clear responsibilities:

- `development`: prototype and test content model changes safely
- `staging`: define and QA content before release
- `live`: production content only

Before making large content changes or running environment-to-environment migrations, take an export backup of the source environment.

## Space export and import

Use the [Contentful CLI](https://github.com/contentful/contentful-cli) for environment backups and restores. This now replaces the old standalone CLI usage of `contentful-export` and `contentful-import`.

Use this for:

- taking a backup of `development`, `staging` or `live` before a merge or migration exercise
- restoring or copying content into another environment
- periodically copying realistic content from `staging` into `development`
- occasional maintenance sync from `production` back into `staging` when content drift has built up

Notes:

- export/import is broader and heavier than `contentful-merge`
- use export/import when you want a snapshot or full restore path
- use `contentful-merge` instead when you want a targeted diff/apply workflow between environments


Prerequisite:

- Node `v24`

Install:

```bash
npm install -g contentful-cli
```

Authentication:

```bash
contentful login
```

This will show a browser window prompting to login with your Contentful credentials and after logging in will present a CMA token that can be pasted back into the terminal window. Once this is done the token argument is not required when working with the `contentful` CLI.

Set local configuration:

```bash
contentful config add --active-space-id <space-id>`
```

This sets the selected space (Contentful instance) as a config value stored in `~/.contentfulrc.json`. Use the value from the ENV var `CONTENTFUL_SPACE_ID` for this. Once set, this avoids having to specify the `--space-id` argument repeatedly in future commands. This need only be done once.

Useful commands:

```bash
contentful space export --help
contentful space import --help
```

Typical export:

```bash
contentful space export --environment-id development
```

This will write a file named e.g. `contentful-export-space-environment-yyyy-mm-ddThh-mm-ss.json`

Typical import:

```bash
contentful space import --environment-id staging --content-file filename.json
```


## Content model changes

Use the [Contentful Merge app](https://www.contentful.com/marketplace/merge/) to compare, review and merge content model changes between environments.

The Merge app is intended for schema changes such as:

- adding, editing or deleting content types
- adding, editing or deleting fields
- changing validations, field settings, help text or appearance

Recommended workflow:

1. Make content model changes in the `development` environment first.
2. Update the application so it supports those changes.
3. When ready, use the Merge app to diff and merge `development` into `staging`.
4. After QA and approval, use the Merge app again to promote the same content model changes from `staging` to `live`.

This keeps schema changes out of `live` until they have been proven.


## Content changes

Use the [contentful-merge CLI](https://github.com/contentful/contentful-merge) to compare and promote entry content between environments.

The CLI is intended for entry migration rather than schema migration:

- it creates a changeset of entry differences between two environments
- it applies that changeset to a target environment
- it compares published entries, not draft-only changes
- merges can be problematic if published entries have linked draft entries as the linked items won't be merged
- merges also do not handle media items; these should be updated manually

Prerequisite:

- Node `v24`

Install:

```bash
npm install -g contentful-merge
```

Token handling:

- `contentful-merge create` uses a CDA token. A dedicated API key token is available within Contentful that has access to all environments (see `Contentful-Merge` under API keys and use the `Content Delivery API - access token` so that only published content is compared)
- `contentful-merge apply` uses a CMA token. These are short lived tokens for Content admin and can be created under `CMA tokens` by clicking `Create personal access token`. Using a short expiry time is recommended.
- do not share these tokens
- do not commit them, save them in project files, or store them for ongoing reuse

Typical usage:

```bash
contentful-merge create --space <space-id> --source staging --target development --cda-token <cda-token>
```

This will create a changeset (essentially a diff) between the specified environments as a .json file in the current directory. The same diff can then be applied to bring the target environment in sync with the source environment.

```bash
contentful-merge apply --space <space-id> --environment development --cma-token <cma-token>  --file changeset-filename.json
```


## Keeping environments aligned

Content should not only move upwards.

Use `contentful-merge` for periodic sync work as well:

- occasionally copy realistic content from `staging` to `development` so automated tests can run against representative data
- because content editing has drifted toward `production`, periodically mirror `production` back to `staging` as a less frequent maintenance exercise

This helps avoid long-term divergence between environments and keeps lower environments useful for testing and QA.


## Summary

- Use the Merge app for content model and schema changes.
- Use `contentful-cli` for export/import backups and restores.
- Prototype schema changes in `development`, then promote to `staging`, then `production`.
- Use `contentful-merge` CLI for entry content migration.
- Define content in `staging`, then promote to `production` after QA and approval.
- Periodically sync `staging` to `development` and, less often, `production` back to `staging`.
