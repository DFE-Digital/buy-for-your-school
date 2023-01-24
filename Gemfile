# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }
ruby "3.2.0"

gem "aasm"
gem "aws-sdk-s3", require: false
gem "bootsnap", ">= 1.1.0", require: false
gem "coffee-rails", "~> 5.0" # TODO: remove coffee-rails, only used for google analytics
gem "contentful", "~> 2.16"
gem "crawler_detect"
gem "cssbundling-rails", "~> 1.1"
gem "dry-struct"
gem "dry-transformer"
gem "dry-validation"
gem "flipper"
gem "flipper-active_record"
gem "flipper-ui"
gem "govuk_design_system_formbuilder", "~> 3.0"
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
gem "pg"
gem "pg_search"
gem "puma", "~> 6"
gem "rails", "~> 7.0.3"
gem "rails_semantic_logger"
gem "redis", "~> 4.5"
gem "redis-namespace"
gem "redis-rails"
gem "rollbar"
gem "scenic"
gem "sidekiq", "~> 6.4"
gem "sidekiq-cron", "~> 1.9"
gem "sprockets-rails"
gem "thor"
gem "turbolinks", "~> 5"
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
gem "uglifier", ">= 1.3.0"
gem "will_paginate", "~> 3.3.0"

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
  gem "listen", ">= 3.0.5", "< 3.8"
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
  gem "rspec-rails"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
  gem "simplecov"
  gem "webmock"
end
