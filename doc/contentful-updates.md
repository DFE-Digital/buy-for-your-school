# Contentful Updates

As more content is added or updated in Contentful, the application needs to be able to handle these changes. This document sets out how changes made in Contentful are managed by our application.

## General

New fields should be added with input from a developer. Significant changes should first be made in the `develop` environment and then copied to the `staging` environment once the application is ready to handle the changes.

## Categories

### Creating categories from `config/categories.yml`

The categories used by the public FABS pages can be created or updated in Contentful with the following rake tasks:

```sh
bundle exec rake contentful:create_ways_to_buy
bundle exec rake contentful:create_subcategories
bundle exec rake contentful:create_categories
```

Run `contentful:create_ways_to_buy` when you need to create or refresh the fixed ways to buy entries used by solutions. Run `contentful:create_subcategories` first when you need to create or refresh the subcategory entries. After that, `contentful:create_categories` can be rerun on its own to map categories to the correct subcategories.

Both tasks require:

- `CONTENTFUL_CMA_TOKEN` this is a temporary admin token that lasts for 30 days
- `CONTENTFUL_SPACE_ID`
- `CONTENTFUL_ENVIRONMENT` if you are not using the default `master`

Note that `CONTENTFUL_CMA_TOKEN` is intentionally not available during deployment to Azure so will have to be manually defined within a terminal session after connecting to Azure environment before running these rake tasks.

### Creating ways to buy entries

The fixed ways to buy entries can be created or updated in Contentful with:

```sh
bundle exec rake contentful:create_ways_to_buy
```

This task creates or updates the following title and slug pairs:

- `Catalogue` → `catalogue`
- `DfE deal` → `dfe_deal`
- `DPS` → `dps`
- `Framework` → `framework`

This task also requires:

- `CONTENTFUL_CMA_TOKEN`
- `CONTENTFUL_SPACE_ID`
- `CONTENTFUL_ENVIRONMENT` if you are not using the default `master`

### Creating redirects from `config/redirects.yml`

Redirect entries can be created or updated in Contentful with:

```sh
bundle exec rake contentful:create_redirects
```

This task reads `config/redirects.yml` and upserts Redirect entries by `source_path`.

Each redirect entry in the YAML file must define:

- `title`
- `source_path`
- `destination_path`
- `redirect_type`

`redirect_type` must be either:

- `permanent`
- `temporary`

The initial `config/redirects.yml` file includes the about-page redirect and the current legacy category redirects.

This task also requires:

- `CONTENTFUL_CMA_TOKEN`
- `CONTENTFUL_SPACE_ID`
- `CONTENTFUL_ENVIRONMENT` if you are not using the default `master`

### Exporting solutions to `config/solutions.yml`

You can export the currently published solutions from Contentful into `config/solutions.yml` with:

```sh
bundle exec rake contentful:export_solutions
```

The exported file contains the `title` and `slug` for each published solution, ordered by slug for stable output.

This task also requires:

- `CONTENTFUL_CMA_TOKEN`
- `CONTENTFUL_SPACE_ID`
- `CONTENTFUL_ENVIRONMENT` if you are not using the default `master`

### Annotating `config/solutions.yml` from the recategorisation spreadsheet

After exporting the initial `config/solutions.yml`, you can enrich it with category, subcategory and buying option data from the recategorisation spreadsheet with:

```sh
bundle exec rake solutions:update_category_mapping
```

This task reads:

- `config/solutions.yml` as the base list of published solutions exported from Contentful
- `config/categories.yml` to translate category and subcategory names to slugs
- `DO NOT EDIT - Categories_BuyingOptions(Recategorising frameworks).csv` as the source spreadsheet data

The spreadsheet must be exported from Excel as `CSV UTF-8 (Comma delimited) (*.csv)`. Other CSV encodings may cause the rake task to misread headers or cell values.

The intended workflow is:

1. Export the current published solutions from Contentful into `config/solutions.yml`
2. Maintain the recategorisation spreadsheet with category, subcategory, buying option and optional slug data
3. Export that spreadsheet from Excel as UTF-8 CSV, replacing `DO NOT EDIT - Categories_BuyingOptions(Recategorising frameworks).csv`
4. Run `bundle exec rake solutions:update_category_mapping` to annotate the exported solutions with:
   - `primary_category`
   - `categories`
   - `subcategories`
   - `ways_to_buy`

Matching is done by `Framework slug` when present. If that column is blank, the task falls back to matching by solution title. If `Framework slug` contains `ignore`, that spreadsheet row is skipped.

The task prints a summary showing unmatched rows, unresolved category or subcategory values, ignored rows, and any solutions still missing mapped data.

### Updating existing Contentful solutions from `config/solutions.yml`

Once `config/solutions.yml` has been annotated with the correct category, subcategory and buying option slugs, you can apply that data back to existing Contentful solution entries with:

```sh
bundle exec rake contentful:update_solutions
```

This task:

- reads the annotated `config/solutions.yml`
- looks up existing published Contentful entries by slug for:
  - solutions
  - categories
  - subcategories
  - ways to buy
- updates existing solution entries with:
  - `primary_category`
  - `categories`
  - `subcategories`
  - `ways_to_buy`

The task does not create new solutions. If a solution slug from `config/solutions.yml` cannot be matched in Contentful, it is reported in the summary and skipped.

If any referenced category, subcategory or ways to buy slug cannot be resolved in Contentful for a given solution, that solution is skipped rather than being partially updated. The task summary reports any unmatched:

- solutions
- categories
- subcategories
- ways to buy
- solutions skipped because of unresolved references

This task also requires:

- `CONTENTFUL_CMA_TOKEN`
- `CONTENTFUL_SPACE_ID`
- `CONTENTFUL_ENVIRONMENT` if you are not using the default `master`
