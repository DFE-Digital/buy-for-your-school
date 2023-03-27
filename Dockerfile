# ------------------------------------------------------------------------------
# Base
# ------------------------------------------------------------------------------
FROM ruby:3.2.1 as base

RUN apt-get update && apt-get install -qq -y \
    build-essential \
    libpq-dev \
    --fix-missing --no-install-recommends

ENV TZ="Europe/London"

# https://github.com/jgm/pandoc/releases/download/2.17.0.1/pandoc-2.17.0.1-1-arm64.deb

RUN wget -q https://github.com/jgm/pandoc/releases/download/2.14.2/pandoc-2.14.2-1-amd64.deb; \
    apt-get install ./pandoc-2.14.2-1-amd64.deb; \
    rm pandoc-2.14.2-1-amd64.deb

RUN apt-get install -qq -y \
    texlive \
    texlive-latex-recommended \
    lmodern \
    --fix-missing --no-install-recommends

# Yarn

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq && apt-get install -y nodejs yarn


# ------------------------------------------------------------------------------
# Assets
# ------------------------------------------------------------------------------
FROM node:alpine as assets

ENV NODE_ENV ${NODE_ENV:-production}

RUN mkdir -p /deps/config/webpack
RUN mkdir -p /deps/script/assets

WORKDIR /deps

COPY yarn.lock /deps/yarn.lock
COPY package.json /deps/package.json
COPY script /deps/script

RUN yarn install

# ------------------------------------------------------------------------------
# Production Stage
# ------------------------------------------------------------------------------
FROM base AS app

ENV APP_HOME /srv/app
ENV RAILS_ENV ${RAILS_ENV:-production}
ENV PATH $PATH:/usr/local/bundle/bin:/usr/local/bin

RUN mkdir -p ${APP_HOME}/tmp/pids ${APP_HOME}/log

WORKDIR ${APP_HOME}

COPY Gemfile $APP_HOME/Gemfile
COPY Gemfile.lock $APP_HOME/Gemfile.lock

RUN bundle config set frozen true
RUN bundle config set no-cache true
RUN bundle config set without development test
RUN bundle install --no-binstubs --retry=10 --jobs=4

COPY config.ru ${APP_HOME}/config.ru
COPY Rakefile ${APP_HOME}/Rakefile
COPY public ${APP_HOME}/public
COPY bin ${APP_HOME}/bin
COPY script ${APP_HOME}/script
COPY lib ${APP_HOME}/lib
COPY config ${APP_HOME}/config
COPY db ${APP_HOME}/db
COPY app ${APP_HOME}/app
COPY yarn.lock ${APP_HOME}/yarn.lock
COPY package.json ${APP_HOME}/package.json
COPY babel.config.js ${APP_HOME}/babel.config.js
COPY .browserslistrc ${APP_HOME}/.browserslistrc

COPY --from=assets /deps/node_modules /srv/node_modules
COPY --from=assets /deps/node_modules $APP_HOME/node_modules

RUN yarn config set ignore-engines true
RUN RAILS_ENV=production SECRET_KEY_BASE=key bundle exec rake assets:precompile

COPY ./docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server"]


# ------------------------------------------------------------------------------
# Development Stage
# ------------------------------------------------------------------------------
FROM app as dev

RUN bundle config unset without
RUN bundle config set without test
RUN bundle install --no-binstubs --retry=10 --jobs=4

# ------------------------------------------------------------------------------
# Test Stage
# ------------------------------------------------------------------------------
FROM app as test

RUN bundle config unset without
RUN bundle config set without development
RUN bundle install --no-binstubs --retry=10 --jobs=4

RUN apt-get install -qq -y shellcheck wait-for-it iproute2

COPY .rubocop.yml ${APP_HOME}/.rubocop.yml
COPY .rubocop_todo.yml ${APP_HOME}/.rubocop_todo.yml
COPY knapsack_rspec_report.json ${APP_HOME}/knapsack_rspec_report.json

COPY .rspec ${APP_HOME}/.rspec
COPY spec ${APP_HOME}/spec
