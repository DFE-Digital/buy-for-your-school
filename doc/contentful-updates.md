# Contentful Updates

As more content is added or updated in Contentful, the application needs to be able to handle these changes. This document sets out how changes made in Contentful are managed by our application.

## General

New fields should be added with input from a developer. Significant changes should first be made in the `develop` environment and then copied to the `staging` environment once the application is ready to handle the changes.

## Categories

A webhook has been added to Contentful to keep track of changes to the `Category` content as it is **published**.

The following fields may be updated with each published change:
- `title`
- `description`
- `liquid_template`
- `slug`

As `liquid_template` determines the content of a user specification, any existing user specification may be affected by changes made to this field. Work to handle this has not yet started.
