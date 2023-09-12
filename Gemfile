# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }
ruby "3.2.1"

gem "aasm"
gem "application_insights"
gem "aws-sdk-s3", require: false
#
# awaiting PR merge here: https://github.com/Azure/azure-storage-ruby/pull/228 due to need for faraday 2
# gem "azure-storage-blob", "~> 2.0", require: false
gem "azure-storage-blob", git: "https://github.com/honeyankit/azure-storage-ruby", ref: "patch-1", require: false
gem "bootsnap", ">= 1.1.0", require: false
gem "coffee-rails", "~> 5.0" # TODO: remove coffee-rails, only used for google analytics
gem "contentful", "~> 2.17"
gem "crawler_detect"
gem "cssbundling-rails", "~> 1.1"
gem "dry-struct"
gem "dry-transformer"
gem "dry-validation"
gem "exception_notification"
gem "flipper"
gem "flipper-active_record"
gem "flipper-ui"
gem "govuk_design_system_formbuilder", "~> 4.1"
gem "httparty"
gem "httpclient"
gem "jbuilder", "~> 2.11"
gem "jquery-rails"
gem "jsbundling-rails"
gem "jwt"
gem "liquid"
gem "loaf"
gem "mini_racer"
gem "notifications-ruby-client"
gem "omniauth"
gem "omniauth_openid_connect"
gem "omniauth-rails_csrf_protection"
gem "pandoc-ruby"
gem "paper_trail"
gem "pg"
gem "pg_search"
gem "puma", "~> 6"
gem "pundit"
gem "rails", "~> 7.0.6"
gem "rails_semantic_logger"
gem "redis", "~> 4.8"
gem "redis-namespace"
gem "redis-rails"
gem "rollbar"
gem "scenic"
gem "sidekiq", "~> 7.1"
gem "sidekiq-cron", "~> 1.10"
gem "simple_xlsx_reader"
gem "slack-notifier"
gem "sprockets-rails"
gem "stimulus-rails"
gem "terser"
gem "thor"
gem "turbo-rails"
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
gem "will_paginate", "~> 4.0.0"
gem "wisper", "2.0.1"

group :development, :test do
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "dotenv-rails"
  gem "i18n-tasks"
  gem "knapsack"
  gem "pry-byebug"
  gem "pry-rails"
  gem "rubocop-govuk", require: false
  gem "rubocop-performance", require: false
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem "foreman"
  gem "listen", ">= 3.8", "< 3.9"
  gem "rails_layout"
  gem "spring"
  gem "spring-commands-rspec"
  # Incompatible with spring 3.0 and higher
  # gem "spring-watcher-listen", "~> 2.0.0"
  gem "web-console", ">= 3.3.0"
  gem "yard-junk"
end

group :test do
  gem "brakeman"
  gem "bullet"
  gem "capybara", ">= 2.15"
  gem "climate_control"
  gem "database_cleaner"
  gem "factory_bot_rails"
  gem "faker"
  gem "mock_redis"
  gem "rails-controller-testing"
  gem "rspec-rails"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
  gem "simplecov"
  gem "webmock"
end
