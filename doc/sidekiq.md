# Sidekiq

Sidekiq is used in GHBS for background job processing, including scheduled recurring jobs defined in `config/schedule.yml`.

When the app is running locally, the Sidekiq web UI is available at:

[`https://localhost:3000/sidekiq`](https://localhost:3000/sidekiq)

The Sidekiq Cron UI is available at:

[`https://localhost:3000/sidekiq/cron`](https://localhost:3000/sidekiq/cron)

Use the cron page to view and control scheduled jobs loaded from `config/schedule.yml`.
