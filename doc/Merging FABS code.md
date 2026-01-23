# Merging FABS Code into BFYS

## Summary

This document tracks the changes made to integrate Find a Buying Solution (FABS) code into Buy For Your School (BFYS). The goal is to make FABS code usable independently of BFYS while avoiding naming conflicts.

## Changes Made

### 1. Model Namespacing

- **Created namespaced FABS models** to avoid conflicts with existing BFYS models:
  - `app/models/FABS/category.rb` - Contentful-backed Category model (conflicts with BFYS database-backed Category)
  - `app/models/FABS/page.rb` - Contentful-backed Page model

- **Updated all references** from `Category` to `FABS::Category` in:
  - `app/controllers/categories_controller.rb`
  - `app/controllers/solutions_controller.rb`
  - `app/controllers/offers_controller.rb`
  - `app/controllers/search_controller.rb`
  - `app/controllers/pages_controller.rb`
  - `app/models/solution.rb`
  - `app/services/solution_searcher.rb`
  - `app/models/concerns/has_related_content.rb`

### 2. Library Files

- **Copied FABS library files** to `lib/`:
  - `lib/gds_design_system_breadcrumb_builder.rb` - Custom breadcrumb builder for breadcrumbs_on_rails
  - `lib/i18n/utils.rb` - I18n utility functions
  - `lib/i18n/backend/contentful.rb` - Contentful-backed I18n backend

- **Updated configuration** in `config/application.rb`:
  - Added `config.autoload_paths << Rails.root.join("lib")` to ensure Rails can find these files

### 3. Controllers

- **Updated FABS controllers** with necessary changes:
  - Added `skip_before_action :authenticate_user!` to all FABS controllers (categories, solutions, offers, search, pages)
  - Updated to use `FABS::Category` instead of `Category`
  - Fixed breadcrumb format to use symbols (`:home_breadcrumb_name, :root_path`) matching original FABS code
  - Added explicit `render layout: "fabs_application"` to FABS actions to avoid layout conflicts

### 4. Layouts

- **Created separate FABS layout**:
  - `app/views/layouts/fabs_application.html.erb` - Direct copy of FABS's `application.html.erb` to avoid conflict with BFYS's `application.html.erb`
  - This layout includes the full FABS structure with sidebar, header, and footer

### 5. Assets and Styling

- **Created separate FABS stylesheet**:
  - `app/assets/stylesheets/fabs.sass.scss` - Complete FABS styling copied from FABS's `application.sass.scss`
  - Configured `@use` directives for `govuk-frontend` and `dfe-frontend`

- **Copied image assets**:
  - `app/assets/images/govuk-frontend/` - All GOV.UK Frontend images (favicon, logos, etc.)
  - `app/assets/images/dfe-frontend/` - All DfE Frontend images

- **Updated asset configuration**:
  - `app/assets/config/manifest.js` - Added `//= link_tree` directives for image directories
  - `config/initializers/assets.rb` - Added `app/assets/builds` to asset paths
  - `package.json` - Added `dfe-frontend` dependency

### 6. Helpers

- **Added FABS helper methods** to `app/helpers/application_helper.rb`:
  - `usability_survey_url` - URL helper for usability survey
  - `customer_satisfaction_survey_url` - URL helper for customer satisfaction survey
  - `fabs_format_date` - Date formatting helper (renamed from `format_date` to avoid conflict with BFYS's `DateHelper#format_date`)

- **Updated FABS views** to use `fabs_format_date` instead of `format_date`

### 7. Translations

- **Merged FABS translations** into `config/locales/en.yml`:
  - Added all FABS-specific translation keys: `breadcrumbs`, `categories`, `header_description`, `header_title`, `offers`, `results`, `search`, `service`, `shared`, `solutions`

### 8. Ruby Compatibility

- **Fixed implicit `it` block parameters** for Ruby 3.3.8 compatibility:
  - Updated all instances of implicit `it` (e.g., `new(it)`) to explicit parameters (e.g., `|entry| new(entry)`)
  - Affected files:
    - `app/models/FABS/category.rb`
    - `app/models/FABS/page.rb`
    - `app/models/solution.rb`
    - `app/models/offer.rb`
    - `app/models/search_client.rb`
    - `app/services/solution_searcher.rb`
    - `app/models/concerns/has_related_content.rb`

### 9. Configuration

- **Environment variables** (`config/initializers/dotenv.rb`):
  - Added requirement for FABS-specific Contentful environment variables: `CONTENTFUL_SPACE_ID`, `CONTENTFUL_ACCESS_TOKEN`

- **Routes** (`config/routes.rb`):
  - Root route now points to `categories#index` (FABS homepage) instead of redirecting

### 10. View Fixes

- **Fixed view errors**:
  - `app/views/shared/_dfe_service_navigation.html.erb` - Fixed `TypeError` with conditional attribute assignment using ternary operator

## Known Issues and Conflicts

### Breadcrumb Gem Conflict

**Issue**: Both `loaf` (BFYS) and `breadcrumbs_on_rails` (FABS) provide `add_breadcrumb` method, causing conflicts when both gems are loaded.

**Current Status**: 
- `loaf` gem is currently enabled in Gemfile
- FABS code uses `breadcrumbs_on_rails` with symbol-based breadcrumb calls (`:home_breadcrumb_name, :root_path`)
- BFYS's `layouts/_breadcrumbs.html.erb` uses `breadcrumb_trail` from `breadcrumbs_on_rails`
- BFYS's `pages_controller.rb` line 55 uses `breadcrumb()` method which may be from `loaf`

**Impact**:
- When `loaf` is installed, it can interfere with FABS breadcrumbs
- When `loaf` is uninstalled, FABS breadcrumbs work correctly
- Need to verify if BFYS-specific code (particularly `pages_controller.rb` line 55) actually requires `loaf` or can use `breadcrumbs_on_rails`

**Potential Solutions**:
1. Remove `loaf` if BFYS code can be migrated to use `breadcrumbs_on_rails`
2. Keep both gems but ensure they don't conflict (may require method aliasing or namespacing)
3. Isolate breadcrumb usage so FABS uses `breadcrumbs_on_rails` and BFYS uses `loaf` without interference

### Layout Conflicts

- BFYS's default `application.html.erb` layout differs significantly from FABS's layout structure
- FABS controllers now explicitly use `render layout: "fabs_application"` to avoid conflicts
- This is resolved but requires explicit layout specification in all FABS controllers

## Files Modified

### Controllers
- `app/controllers/categories_controller.rb`
- `app/controllers/solutions_controller.rb`
- `app/controllers/offers_controller.rb`
- `app/controllers/search_controller.rb`
- `app/controllers/pages_controller.rb`

### Models
- `app/models/FABS/category.rb` (created)
- `app/models/FABS/page.rb` (created)
- `app/models/solution.rb`
- `app/models/offer.rb`
- `app/models/search_client.rb`
- `app/models/concerns/has_related_content.rb`

### Services
- `app/services/solution_searcher.rb`

### Views
- `app/views/shared/_dfe_service_navigation.html.erb`
- `app/views/layouts/fabs_application.html.erb` (created)

### Helpers
- `app/helpers/application_helper.rb`

### Configuration
- `config/application.rb`
- `config/routes.rb`
- `config/initializers/dotenv.rb`
- `config/initializers/assets.rb`
- `config/locales/en.yml`

### Assets
- `app/assets/stylesheets/fabs.sass.scss` (created)
- `app/assets/config/manifest.js`
- `app/assets/images/govuk-frontend/` (copied)
- `app/assets/images/dfe-frontend/` (copied)

### Library
- `lib/gds_design_system_breadcrumb_builder.rb` (copied)
- `lib/i18n/utils.rb` (copied)
- `lib/i18n/backend/contentful.rb` (copied)

### Dependencies
- `Gemfile` - `breadcrumbs_on_rails` already present
- `package.json` - Added `dfe-frontend`
