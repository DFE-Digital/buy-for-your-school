# GHBS public frontend integration plan

The GHBS public-facing (“FABS”) frontend is already copied into the repo but is
currently tangled with the rest of the stack. The merge must land in small,
reviewable increments so that the case-management portals stay stable on Rails 7
while the new frontend is dark-launched behind a feature flag.

## 1. Baseline checks

* Confirm the branch can boot locally on Rails 7 with `bundle exec rails s`
  using the current `.env.example`. Note every missing/incorrect environment
  variable so the sample files can be updated during the first PR.
* Capture the current list of Contentful secrets, OpenSearch endpoints, and the
  existing `GHBS_HOMEPAGE_URL` redirect target. These are referenced across
  `app/models/contentful_client.rb`, `config/routes.rb`, and
  `app/controllers/fabs/application_controller.rb`.
* Inventory the imported files (see `doc/Merging FABS code.md`) and the test
  suites under `spec/fabs` to understand the review surface.

## 2. Feature flag and environment plumbing

1. Ship `Fabs::ApplicationController` plus the `:ghbs_public_frontend` Flipper
   flag on its own branch and enable it in the development environment
   immediately after deployment. The controller should temporarily redirect to
   `ENV["GHBS_HOMEPAGE_URL"]`, so toggling the flag on early is safe.
2. Update `.env.example`, `.env.test`, the developer docs, and
   `config/initializers/dotenv.rb` so that `CONTENTFUL_SPACE_ID`,
   `CONTENTFUL_ACCESS_TOKEN`, `CONTENTFUL_WEBHOOK_SECRET`, `GHBS_SERVER_URL`,
   `OPENSEARCH_URL`, etc., are documented and required.
3. Add a short entry to `doc/feature-flags.md` describing the new flag.
4. Deploy this change with the flag disabled everywhere; nothing should
   reference the controller yet, so behaviour stays the same.

## 3. Contentful data layer

1. Introduce the namespaced Contentful models (`FABS::Category`,
   `FABS::Page`, Contentful-backed `Solution`, `Offer`, `Banner`,
   `HasRelatedContent`, and `ContentfulRecordNotFoundError`) plus their specs
   and VCR helpers.
2. Validate the models in isolation by running `bundle exec rspec spec/fabs`.
3. Keep the controllers/views untouched so reviewers focus on the data layer.

## 4. Controllers, routes, and breadcrumbs

1. Add the public controllers (`categories`, `solutions`, `offers`, `search`,
   `pages`, `events`) and the FABS routes to `config/routes.rb`.
2. Make every controller inherit from `Fabs::ApplicationController` so that,
   with the feature flag already enabled in development, requests now hit the
   new actions instead of redirecting.
3. Resolve the breadcrumb conflict: either remove `loaf` or ensure
   `app/controllers/concerns/breadcrumbs.rb` plus
   `lib/gds_design_system_breadcrumb_builder.rb` provide the single breadcrumb
   API used across the app.
4. Keep layouts/views in a later PR to reduce noise.

## 5. Layouts, shared partials, and assets

1. Add the GHBS layouts (`app/views/layouts/fabs_application.html.erb`,
   `homepage`, `all_buying_options`, etc.) and shared partials under
   `app/views/shared`.
2. Import `app/assets/stylesheets/fabs.sass.scss`, images, and JavaScript
   controllers (search toggle, analytics tracking). Scope the styles so they
   apply only when the GHBS layout renders, avoiding regressions in the portals.
3. Update `app/assets/config/manifest.js`, `package.json`, and
   `config/initializers/assets.rb` as needed, but keep the diff focused on
   asset loading.
4. Once these layouts are wired up, start running full-stack smoke tests in the
   development environment with the flag already on.

## 6. Search and analytics plumbing

1. Land the OpenSearch pieces (`SearchClient`, `SolutionSearcher`,
   `SolutionIndexer`) plus the `/events` endpoint used by the tracking
   controllers.
2. Wire up the search views (`app/views/search`) and ensure the header
   search forms respect `@show_search_in_header`.
3. Update the CSP if additional domains (e.g., telemetry endpoints) need to be
   whitelisted.

## 7. Contentful webhooks and framework sync

1. Fix `ContentfulWebhooksController` so it skips authentication, verifies the
   HMAC signature, and returns valid HTTP status symbols.
2. Refactor `Support::SyncFrameworks` to pull from local Contentful data or
   reindex via the webhook, then downgrade the cron job to a fallback/manual
   task.
3. Document the new webhook secrets and rollout steps in `doc/webhooks.md`.

## 8. Dark-launch and QA

1. Merge main into the integration branch once every slice above is reviewed.
2. Enable `:ghbs_public_frontend` only in the development environment and run
   the GHBS spec suite plus manual smoke tests (home page, categories, search,
   content pages).
3. Repeat in staging; fix any regressions, especially around shared helpers,
   layouts, and breadcrumbs.
4. When confident, schedule a production dark-launch window, enable the flag
   for internal users first (Flipper groups), then ramp up gradually.
5. Remove the legacy redirects and duplicate styles/translations once the new
   frontend has been live without issues.

Delivering the migration through these slices keeps each review focused, limits
the risk of regressions in the existing portals, and provides clear rollback
points while the feature flag remains disabled. Each step builds on the
previous one until the new GHBS frontend can be turned on safely.
