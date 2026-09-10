# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }
ruby file: ".ruby-version"

gem "aasm"
gem "application_insights"
gem "ar-sequence"
gem "aws-sdk-s3", require: false
gem "azure-blob", "~> 0.8", require: false
gem "bootsnap", ">= 1.24.4", require: false
gem "breadcrumbs_on_rails"
gem "contentful", "~> 2.19"
gem "contentful-management", require: false
gem "crawler_detect"
gem "cssbundling-rails", "~> 1.4"
gem "dfe-analytics", github: "DFE-Digital/dfe-analytics", tag: "v1.15.17"
gem "dry-struct"
gem "dry-transformer"
gem "dry-validation"
gem "exception_notification"
gem "flipper"
gem "flipper-active_record"
gem "flipper-ui"
gem "govuk-components", "~> 6.4", ">= 6.4.0"
gem "govuk_design_system_formbuilder", "~> 5"
gem "httparty"
gem "httpclient"
gem "jbuilder", "~> 2.14"
gem "jsbundling-rails"
gem "jwt"
gem "kramdown"
gem "liquid"
gem "loaf"
gem "mini_racer"
gem "notifications-ruby-client"
gem "omniauth"
gem "omniauth_openid_connect"
gem "omniauth-rails_csrf_protection"
gem "opensearch-ruby"
gem "pandoc-ruby"
gem "paper_trail"
gem "pdf-forms"
gem "pg"
gem "pg_search"
gem "puma", "~> 7"
gem "pundit"
gem "rails", "~> 8"
gem "rake"
gem "redis", "~> 4.8"
gem "redis-namespace"
gem "redis-rails"
gem "rollbar"
gem "rubyXL"
gem "scenic"
gem "sidekiq", "~> 6.4"
gem "sidekiq-cron", "~> 2.4"
gem "simple_xlsx_reader"
gem "sitemap_generator"
gem "sprockets-rails"
gem "stimulus-rails"
gem "terser"
gem "thor"
gem "turbo-rails"
gem "tzinfo-data", platforms: %i[windows jruby]
gem "wicked_pdf"
gem "will_paginate", "~> 4.0.0"
gem "wisper", "3.0.0"
gem "wkhtmltopdf-binary"

group :development, :test do
  gem "byebug", platforms: %i[mri windows]
  gem "dotenv-rails"
  gem "guard-rspec", require: false
  gem "i18n-tasks"
  gem "knapsack"
  gem "pry-byebug"
  gem "pry-rails"
  gem "readline"
  gem "rubocop-govuk", require: false
  gem "rubocop-performance", require: false
  gem "ruby-lsp-rails"
  gem "ruby-lsp-rspec", require: false
  gem "terminal-notifier"
  gem "terminal-notifier-guard", "~> 1.7.0"
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem "foreman"
  gem "listen", ">= 3.8", "< 3.10"
  gem "spring"
  gem "spring-commands-rspec"
  # Incompatible with spring 3.0 and higher
  # gem "spring-watcher-listen", "~> 2.0.0"
  gem "web-console", ">= 3.3.0"
end

group :test do
  gem "brakeman"
  gem "capybara", ">= 2.15"
  gem "climate_control"
  gem "cuprite"
  gem "database_cleaner"
  gem "factory_bot_rails"
  gem "faker"
  gem "mock_redis"
  gem "rails-controller-testing"
  gem "redis-client"
  gem "rspec-rails"
  gem "shoulda-matchers"
  gem "simplecov", "~> 1.2"
  gem "webmock"
end

gem "bundle-audit", "~> 0.2.0"
