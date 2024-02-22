# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# JS-bundling
Rails.application.config.assets.paths << Rails.root.join("app/javascript")

# Add the GOVUK Frontend assets paths
Rails.application.config.assets.paths << Rails.root.join("node_modules/govuk-frontend/dist/govuk/assets")
Rails.application.config.assets.paths << Rails.root.join("node_modules/govuk-frontend/dist/govuk/assets/images")
Rails.application.config.assets.paths << Rails.root.join("node_modules/govuk-frontend/dist/govuk/assets/fonts")

### PLEASE NOTE - DUE TO THE WAY govuk-frontend WORKS THE PRODUCTION SERVER SERVES NON DIGESTED
###               VERSIONS OF SOME ASSETS DUE TO THE CSS NOT REFERENCING DIGESTED VERSIONS
### PLEASE SEE  - https://github.com/DFE-Digital/rails-template/pull/8
###             - https://frontend.design-system.service.gov.uk/importing-css-assets-and-javascript/#copy-the-font-and-image-files-into-your-application
###             - ./script/assets/copy-assets.sh

# Add GOVUK assets by name, these are assets not loaded via sass
Rails.application.config.assets.precompile += [
  "images/favicon.ico",
  "images/govuk-apple-touch-icon-152x152.png",
  "images/govuk-apple-touch-icon-167x167.png",
  "images/govuk-apple-touch-icon-180x180.png",
  "images/govuk-apple-touch-icon.png",
  "images/govuk-crest-2x.png",
  "images/govuk-crest.png",
  "images/govuk-logotype-crown.png",
  "images/govuk-mask-icon.svg",
  "images/govuk-opengraph-image.png",

  "images/favicon.svg",
  "images/govuk-icon-180.png",
  "images/govuk-icon-192.png",
  "images/govuk-icon-512.png",
  "images/govuk-icon-mask.svg",
]

# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join("node_modules")

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.

# Add TinyMce To precompile (is referenced seperately to application.js)
# NOTE: it's static assets are copied to public/assets/tinymce to be served
# See: ./script/assets/copy-assets.sh
Rails.application.config.assets.precompile << "tinymce/tinymce.min.js"
