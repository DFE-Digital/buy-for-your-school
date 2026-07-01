# Update GOV.UK Publishing Files

This repository keeps a local copy of the GOV.UK publishing files needed for the super navigation header and search components.

The CSS and image assets are copied into `vendor/assets` and the Ruby helper is copied into `lib/` so they can be tracked in this repository without pulling the full gem and its runtime dependencies into the Rails boot path.

## Script

Run the update script from the project root:

```sh
bin/update_govuk_publishing_files
```

The script:

- checks out `govuk_publishing_components` at the version pinned in the script
- uses a sparse checkout so only the required Sass, image, and Ruby helper files are fetched
- copies the selected files into `vendor/assets/stylesheets`, `vendor/assets/images`, and `lib/`
- leaves the checked out repository in `tmp/govuk_publishing_components` for inspection

## Existing checkout

If you already have a checkout that you want to reuse while debugging, set:

```sh
GOVUK_PUBLISHING_COMPONENTS_CHECKOUT_ROOT=/private/tmp/govuk_publishing_components_inspect
```

This lets the script copy from an existing local checkout without cloning again.

## Files copied

The script currently copies the Sass needed for:

- the super navigation header
- search

It also copies the `icon-close.svg` asset used by the search styles.

It also copies:

- `lib/govuk_publishing_components/presenters/component_wrapper_helper.rb`
- `lib/govuk_publishing_components/presenters/shared_helper.rb`

## Notes

- The current workflow updates CSS, related image assets, and the component wrapper helper Ruby file.
- JavaScript for these components is expected to be reimplemented separately in this application.
- After running the script, update the Sass compiler load paths if needed so it can resolve the files under `vendor/assets/stylesheets`.
