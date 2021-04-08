# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }
ruby "2.6.6"

gem "bootsnap", ">= 1.1.0", require: false
gem "climate_control"
gem "coffee-rails", "~> 5.0"
gem "contentful", "~> 2.16"
gem "govuk_design_system_formbuilder", "~> 2.2"
gem "high_voltage"
gem "htmltoword"
gem "jbuilder", "~> 2.11"
gem "jquery-rails"
gem "liquid"
gem "pg"
gem "mini_racer"
gem "omniauth"
gem "omniauth_openid_connect"
gem "omniauth-rails_csrf_protection"
gem "puma", "~> 5.2"
gem "redcarpet", "~> 3.5"
gem "redis", "~> 4.2"
gem "redis-namespace"
gem "rollbar"
gem "rails", "~> 6.1.3"
gem "sass-rails", "~> 6.0"
gem "sidekiq", "~> 6.2"
gem "sidekiq-cron", "~> 1.2"
gem "turbolinks", "~> 5"
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
gem "uglifier", ">= 1.3.0"

group :development do
  gem "listen", ">= 3.0.5", "< 3.6"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "web-console", ">= 3.3.0"
end

group :test do
  gem "capybara", ">= 2.15"
  gem "mock_redis"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
  gem "simplecov"
  gem "webmock"
end

group :development do
  gem "better_errors"
  gem "rails_layout"
  gem "spring-commands-rspec"
end

group :development, :test do
  gem "brakeman"
  gem "bullet"
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "dotenv-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem "pry"
  gem "rspec-rails"
  gem "standard"
end

group :test do
  gem "database_cleaner"
  gem "launchy"
end
