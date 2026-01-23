# Merging FABS Code into BFYS

## Summary

This document tracks the changes made to integrate Find a Buying Solution (FABS) code into Buy For Your School (BFYS). 

**Important Context**: The term "FABS" is outdated. The unified application will be called **Get Help Buying for Schools (GHBS)**, which is the actual DfE service name. The current namespacing and "FABS" terminology throughout this codebase are **temporary** - they exist only to:
1. Avoid naming conflicts during the merge
2. Mark code that needs eventual unification

**Long-term Vision**: One unified GHBS website combining:
- **Public-facing frontend** (currently called "FABS") - for school users to find buying solutions
- **Case management backend** (BFYS) - for proc ops staff to manage cases

The end goal is a single unified codebase with:
- One design system, one set of layouts/styles
- No "FABS" namespace or terminology
- Unified navigation that adapts based on user role (public vs. authenticated)

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

## Strategy for deployment

### 1. Using Feature Flags

**Goal**: Gradually roll out the unified GHBS frontend, starting with dev environment only, to enable QA and manual testing without affecting production.

**Important**: The feature flag controls the **unified GHBS public-facing frontend** (not "FABS integration"). When disabled, users are redirected to the old separate FABS site.

**Implementation Approach**:

1. **Create a base controller** for public-facing routes (similar to `Energy::ApplicationController`):
   ```ruby
   # app/controllers/public/application_controller.rb (or ghbs/public/application_controller.rb)
   class Public::ApplicationController < ApplicationController
     skip_before_action :authenticate_user!
     before_action :check_public_frontend_flag
     
     private
     
     def check_public_frontend_flag
       unless Flipper.enabled?(:ghbs_public_frontend)
         # Redirect to old FABS site
         redirect_to ENV.fetch("FABS_EXTERNAL_URL", "https://find-a-buying-solution.education.gov.uk"), status: :temporary_redirect
       end
     end
   end
   ```

2. **Update public-facing controllers** to inherit from this base:
   - `CategoriesController` → `Public::CategoriesController < Public::ApplicationController`
   - `SolutionsController` → `Public::SolutionsController < Public::ApplicationController`
   - `OffersController` → `Public::OffersController < Public::ApplicationController`
   - `SearchController` → `Public::SearchController < Public::ApplicationController`
   - `PagesController` → `Public::PagesController < Public::ApplicationController`

3. **Wrap routes conditionally** (alternative approach if you want route-level control):
   ```ruby
   # config/routes.rb
   constraints ->(request) { Flipper.enabled?(:ghbs_public_frontend) } do
     root "categories#index"
     resources :categories, only: %i[show index], param: :slug
     # ... other public routes
   end
   ```

4. **Default behavior when flag is OFF**:
   - Redirect root and public routes to external FABS site (via `ENV["FABS_EXTERNAL_URL"]`)
   - Keep BFYS case management functionality unaffected (always accessible to authenticated users)

5. **Rollout strategy**:
   - **Dev**: Enable flag immediately for testing
   - **Staging**: Enable after dev validation
   - **Production**: Enable gradually (maybe percentage-based rollout via Flipper groups)

6. **Add to feature flags documentation** (`doc/feature-flags.md`):
   ```
   |ghbs_public_frontend|Enable unified GHBS public-facing frontend. When disabled, redirects to external FABS site.|DISABLED|Enable in dev for testing|
   ```

**Benefits**:
- Can test thoroughly in dev without affecting other environments
- Easy rollback if issues found
- Can enable for specific users/groups for beta testing
- No code changes needed to toggle - just flip the flag

### 2. Keeping Up with Ongoing Changes in FABS Code

**Problem**: FABS repo will continue to receive updates while we're testing the merged codebase, creating risk of drift.

**Recommended Process**:

1. **Create a sync checklist** (`doc/fabs-sync-checklist.md`):
   - List of files/directories that need syncing
   - Process for identifying what changed
   - Testing requirements after sync

2. **Use git to track changes**:
   ```bash
   # In FABS repo, identify commits since last sync
   git log --since="2026-01-22" --oneline --name-only
   
   # Compare specific files
   diff -u /path/to/fabs/app/models/category.rb /path/to/bfys/app/models/FABS/category.rb
   ```

3. **Automated sync script** (optional):
   ```ruby
   # lib/tasks/fabs_sync.rake
   namespace :fabs do
     desc "Sync changes from FABS repo"
     task :sync, [:fabs_repo_path] => :environment do |_t, args|
       fabs_path = args[:fabs_repo_path] || ENV["FABS_REPO_PATH"]
       # Script to copy files and update namespacing
     end
   end
   ```

4. **Manual sync process**:
   - **Weekly sync meetings** to review FABS changes
   - **Change log** in FABS repo commits (tag with `[needs-sync]`)
   - **Sync priority**:
     1. Critical bug fixes (sync immediately)
     2. New features (sync before next release)
     3. Refactoring (sync when convenient)

5. **Files that typically need syncing**:
   - Models: `app/models/category.rb`, `app/models/page.rb`, `app/models/solution.rb`, etc.
   - Controllers: All FABS controllers
   - Views: All FABS views
   - Helpers: `app/helpers/application_helper.rb` (FABS-specific methods)
   - Styles: `app/assets/stylesheets/application.sass.scss` → `fabs.sass.scss`
   - Translations: FABS-specific keys in `config/locales/en.yml`
   - Tests: `spec/fabs/**/*_spec.rb`
   - VCR cassettes: `spec/fixtures/vcr_cassettes/`

6. **Namespacing considerations**:
   - When syncing, remember to update:
     - `Category` → `FABS::Category`
     - `Page` → `FABS::Page`
     - Controller class names if moving to `Fabs::` namespace
     - Route helpers if controllers are namespaced

7. **Testing after sync**:
   - Run FABS test suite: `rspec spec/fabs/`
   - Manual QA of critical user journeys
   - Check for new dependencies (gems, npm packages)

8. **Documentation**:
   - Keep a log in `doc/Merging FABS code.md` of sync dates and major changes
   - Note any conflicts or manual interventions needed

**Alternative: Git Subtree/Submodule** (not recommended for this use case):
- Could use git subtree to pull FABS changes, but namespacing makes this complex
- Manual sync is clearer and more maintainable given the namespacing requirements

### 3. Improving Code Quality

**Current State (Intentional Temporary Scaffolding)**:
- Duplication: Helpers, layouts, styles, translations (temporary - will be unified)
- Temporary namespacing (`FABS::Category`, `FABS::Page`) - marks code for eventual unification
- Explicit layout rendering in every controller (temporary separation)
- Mixed concerns (public frontend and case management code) - will be unified

**Important**: This duplication is **intentional temporary scaffolding**, not technical debt to fix immediately. The goal is:
1. ✅ Get it working (current state)
2. Test thoroughly with feature flags
3. Unify gradually (merge layouts, styles, remove namespacing)
4. Remove "FABS" terminology entirely

**Improvement Strategy**:

#### Phase 1: Keep Temporary Structure (Now)

**Accept the current state** - it's fine for now:
- Keep `FABS::Category`, `FABS::Page` namespacing temporarily
- Keep separate `fabs_application.html.erb` layout temporarily
- Keep `fabs.sass.scss` temporarily
- This is acceptable as a temporary migration state

#### Phase 2: Gradual Unification (During Testing)

1. **Merge layouts**:
   - Create unified `application.html.erb` that works for both public and admin
   - Use conditional rendering based on user role/route
   - Remove `fabs_application.html.erb` once unified

2. **Merge styles**:
   - Consolidate into one stylesheet with shared components
   - Remove `fabs.sass.scss` once styles are unified
   - Single design system throughout

3. **Organize controllers**:
   - Move public-facing controllers to `Public::` namespace (or `Ghbs::Public::`)
   - Keep case management in `Support::`, `Engagement::`, etc.
   - Clear separation by user role, not by "FABS vs BFYS"

#### Phase 3: Remove Temporary Namespacing (Post-Launch)

**Only after public frontend is live and stable**:

1. **Remove `FABS::` namespace from models**:
   - Rename `FABS::Category` → `Category` (Contentful-backed)
   - Rename `FABS::Page` → `Page` (Contentful-backed)
   - Remove or rename BFYS's database-backed `Category` model (if still exists)
   - Update all references

2. **Remove "FABS" terminology**:
   - Rename all "FABS" references to "GHBS" or remove entirely
   - Update comments, documentation, variable names
   - Single unified GHBS codebase

3. **Unified navigation**:
   - Single header/footer that adapts based on user role
   - Public users see: Home, Categories, Solutions, etc.
   - Authenticated users see: Cases, Support, etc. (case management)

**Timeline Recommendation**:
- **Phase 1**: Current state - acceptable temporary scaffolding
- **Phase 2**: During feature flag testing in dev - gradual unification
- **Phase 3**: After public frontend is live in production - major cleanup

**Key Insight**: The namespacing serves dual purpose:
1. **Short-term**: Avoid conflicts with existing BFYS models
2. **Long-term**: Mark code that needs unification (not permanent separation)

The end state is a unified GHBS codebase with no "FABS" terminology.

### 4. Sync Frameworks Functionality

**Current State**: BFYS has a `SyncFrameworks` service that calls an external FABS API endpoint to fetch solutions/frameworks data and sync it into the BFYS database.

**How it works now**:
- **Service**: `app/services/support/sync_frameworks.rb`
- **Job**: `app/jobs/support/sync_frameworks_job.rb`
- **Schedule**: Runs twice daily (midnight and midday) via Sidekiq cron (`config/schedule.yml`)
- **Endpoint**: Calls external API at `ENV["FAF_FRAMEWORK_ENDPOINT"]` (currently points to FABS API)
- **Purpose**: Fetches solutions data from FABS and persists it to `Frameworks::Framework` model in BFYS database
- **API Endpoint**: The FABS repo provides `/bfys/solutions` JSON endpoint (`Bfys::SolutionsController`)

**Why this becomes redundant**:
1. **API endpoint moves**: The `/bfys/solutions` endpoint will be in the same repo (no external API call needed)
2. **Real-time updates**: Can use Contentful webhooks to update framework data in real-time instead of polling twice daily
3. **No data sync needed**: Both public frontend and case management will read from the same Contentful source

**Migration Strategy**:

#### Option 1: Use Contentful Webhooks (Recommended)

1. **Leverage existing webhook infrastructure**:
   - `ContentfulWebhooksController` already handles solution updates/deletions
   - Extend it to also update `Frameworks::Framework` records when solutions change
   - Real-time updates instead of batch polling

2. **Implementation**:
   ```ruby
   # In ContentfulWebhooksController#create
   # After indexing solution in OpenSearch, also update Framework record
   if solution.present?
     FrameworkSyncService.new(solution).sync_to_database
   end
   ```

3. **Remove sync job**:
   - Disable cron job in `config/schedule.yml`
   - Keep `SyncFrameworks` service for manual sync if needed (via admin UI)
   - Or remove entirely if webhooks handle all updates

#### Option 2: Internal API Call (Fallback)

1. **Point endpoint to internal route**:
   - Change `FAF_FRAMEWORK_ENDPOINT` to point to internal route: `http://localhost:3000/bfys/solutions` (dev) or internal service URL (prod)
   - Keep sync job running but call internal endpoint instead of external

2. **Benefits**: Minimal code changes, keeps existing sync logic
3. **Drawbacks**: Still polling-based, not real-time

#### Option 3: Direct Contentful Access (Alternative)

1. **Remove API layer entirely**:
   - Both public frontend and case management read directly from Contentful
   - No database sync needed for frameworks
   - Use Contentful as single source of truth

2. **Benefits**: Simplest architecture, no sync complexity
3. **Drawbacks**: May require refactoring case management code that currently reads from database

**Recommended Approach**: **Option 1 (Contentful Webhooks)**

**Migration Steps**:
1. **Extend webhook handler** to update `Frameworks::Framework` records
2. **Test webhook updates** in dev environment
3. **Disable sync cron job** once webhooks are verified
4. **Keep manual sync option** in admin UI for one-time fixes if needed
5. **Remove `FAF_FRAMEWORK_ENDPOINT` env var** once external API is no longer called
6. **Update documentation** to reflect new real-time update mechanism

**Files to modify**:
- `app/controllers/contentful_webhooks_controller.rb` - Add framework sync logic
- `config/schedule.yml` - Disable `sync_frameworks` cron job
- `app/services/support/sync_frameworks.rb` - Keep for manual sync or remove
- `.env.example` - Remove `FAF_FRAMEWORK_ENDPOINT` (or mark as deprecated)

**Timeline**:
- **Before unification**: Keep sync job running (external API still needed)
- **During unification**: Implement webhook-based updates in parallel
- **After unification**: Disable sync job, remove external API dependency 


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

## Deployment Strategy

### Can we deploy the current merge state to dev immediately?

**Short answer**: **Yes, but with feature flags disabled initially**.

**Recommended approach**: **Deploy in small increments** for safety:

#### Increment 1: Infrastructure & Dependencies (Low Risk)
**Deploy immediately**:
- ✅ All FABS code is already merged (models, controllers, views, assets)
- ✅ Tests are copied and updated
- ✅ VCR cassettes are in place
- ✅ No breaking changes to existing BFYS functionality
- ✅ Feature flag can be disabled to keep public routes pointing to external FABS site

**What to deploy**:
- All merged code (already done)
- Feature flag infrastructure (create flag, but keep it **DISABLED**)
- Environment variables for FABS Contentful (`CONTENTFUL_SPACE_ID`, etc.)

**Risk**: Low - existing BFYS functionality unaffected, public routes redirect when flag is off

#### Increment 2: Enable Feature Flag in Dev (Medium Risk)
**After Increment 1 is verified**:
- Enable `:ghbs_public_frontend` flag **only in dev environment**
- Test public-facing routes (homepage, categories, solutions, search)
- Verify no conflicts with case management routes
- Monitor for errors, performance issues

**Risk**: Medium - first time public routes are active, but isolated to dev

#### Increment 3: Fix Issues Found in Dev (Ongoing)
- Address any bugs, conflicts, or performance issues
- Iterate based on testing feedback
- Keep flag disabled in staging/production

#### Increment 4: Enable in Staging (After Dev Validation)
- Enable flag in staging environment
- Full QA testing
- Load testing if needed

#### Increment 5: Gradual Production Rollout
- Enable flag for percentage of users (via Flipper groups)
- Monitor metrics, error rates
- Gradually increase percentage
- Full rollout when confident

**Why incremental deployment is safer**:
1. **Isolation**: Each increment can be rolled back independently
2. **Testing**: Issues caught early in dev, not production
3. **Confidence**: Build confidence with each successful increment
4. **Risk mitigation**: Feature flag allows instant rollback if issues found

**What NOT to deploy immediately**:
- ❌ Don't enable feature flag in production
- ❌ Don't remove external FABS API dependency yet (sync frameworks still needs it)
- ❌ Don't remove "FABS" namespacing yet (still needed to avoid conflicts)

**Pre-deployment checklist**:
- [ ] All tests passing (`rspec spec/fabs/`)
- [ ] Feature flag created but disabled
- [ ] Environment variables configured
- [ ] External FABS site URL configured for redirects
- [ ] Monitoring/alerting in place
- [ ] Rollback plan documented
