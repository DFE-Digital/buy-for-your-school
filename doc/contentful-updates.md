# Contentful Updates

As more content is added or updated in Contentful, the application needs to be able to handle these changes. This document sets out how changes made in Contentful are managed by our application.

## General

New fields should be added with input from a developer. Significant changes should first be made in the `develop` environment and then copied to the `staging` environment once the application is ready to handle the changes.

## Categories

### Creating categories from `config/categories.yml`

The categories used by the public FABS pages can be created or updated in Contentful with the following rake tasks:

```sh
bundle exec rake contentful:create_subcategories
bundle exec rake contentful:create_categories
```

Run `contentful:create_subcategories` first when you need to create or refresh the subcategory entries. After that, `contentful:create_categories` can be rerun on its own to map categories to the correct subcategories.

Both tasks require:

- `CONTENTFUL_CMA_TOKEN` this is a temporary admin token that lasts for 30 days
- `CONTENTFUL_SPACE_ID`
- `CONTENTFUL_ENVIRONMENT` if you are not using the default `master`

Note that `CONTENTFUL_CMA_TOKEN` is intentionally not available during deployment to Azure so will have to be manually defined within a terminal session after connecting to Azure environment before running these rake tasks.
