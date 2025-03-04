# #!/bin/sh

# # Add govuk assets public images
mkdir -p public/assets/fonts
mkdir -p public/assets/images
cp -r node_modules/govuk-frontend/dist/govuk/assets/fonts/* public/assets/fonts
cp -r node_modules/govuk-frontend/dist/govuk/assets/images/* public/assets/images
cp -r node_modules/dfe-frontend/packages/assets/dfe-logo.png public/assets/images
cp -r node_modules/dfe-frontend/packages/assets/dfe-logo-alt.png public/assets/images

# # Add tinymce assets
mkdir -p public/assets/tinymce
cp -r node_modules/tinymce/* public/assets/tinymce
