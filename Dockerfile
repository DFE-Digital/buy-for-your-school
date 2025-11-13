# ------------------------------------------------------------------------------
# Base
# ------------------------------------------------------------------------------
FROM ruby:3.3.8-slim AS base

ENV TZ="Europe/London"

RUN \
  apt-get update && \
  apt-get install -qq -y --fix-missing --no-install-recommends \
    build-essential \
    curl \
    git \
    gnupg2 \
    libpq-dev \
    libyaml-dev \
    lmodern \
    nodejs \
    npm \
    texlive \
    texlive-latex-recommended \
    wget \
    pdftk-java \
    && \
  curl --silent --location --output pandoc.deb \
    https://github.com/jgm/pandoc/releases/download/2.14.2/pandoc-2.14.2-1-amd64.deb && \
  apt-get install -qq -y --fix-missing --no-install-recommends ./pandoc.deb && \
  rm pandoc.deb && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  ln -s /usr/bin/pdftk-java /usr/local/bin/pdftk && \
  ln -sf /usr/bin/pdftk /usr/local/bin/pdftk && \
  npm install --global yarn

# ------------------------------------------------------------------------------
# Assets
# ------------------------------------------------------------------------------
FROM node:22.4.1-alpine AS assets

ARG NODE_ENV=production

ENV NODE_ENV=${NODE_ENV}

RUN mkdir -p /deps/config/webpack /deps/script/assets

WORKDIR /deps

COPY yarn.lock /deps/yarn.lock
COPY package.json /deps/package.json
COPY script /deps/script

RUN yarn install

# ------------------------------------------------------------------------------
# Production Stage
# ------------------------------------------------------------------------------
FROM base AS app

ARG RAILS_ENV=production

ENV APP_HOME=/srv/app
ENV RAILS_ENV=${RAILS_ENV}
ENV PATH=$PATH:/usr/local/bundle/bin:/usr/local/bin

RUN mkdir -p ${APP_HOME}/tmp/pids ${APP_HOME}/log

WORKDIR ${APP_HOME}

COPY .ruby-version ${APP_HOME}/.ruby-version
COPY Gemfile $APP_HOME/Gemfile
COPY Gemfile.lock $APP_HOME/Gemfile.lock

RUN \
  bundle config set frozen true && \
  bundle config set no-cache true && \
  bundle config set without development test && \
  bundle install --no-binstubs --retry=10 --jobs=4

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

RUN \
  yarn config set ignore-engines true && \
  RAILS_ENV=${RAILS_ENV} SECRET_KEY_BASE=key GHBS_HOMEPAGE_URL=https://example.com bundle exec rake assets:precompile

COPY ./docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server"]


# ------------------------------------------------------------------------------
# Development Stage
# ------------------------------------------------------------------------------
FROM app AS dev

RUN \
  bundle config unset without && \
  bundle config set without test && \
  bundle install --no-binstubs --retry=10 --jobs=4

# ------------------------------------------------------------------------------
# Test Stage
# ------------------------------------------------------------------------------
FROM app AS test

RUN \
  bundle config unset without && \
  bundle config set without development && \
  bundle install --no-binstubs --retry=10 --jobs=4 && \
  apt-get update && \
  apt-get install -qq -y --fix-missing --no-install-recommends \
    iproute2 \
    shellcheck \
    wait-for-it \
    && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

COPY .rubocop.yml ${APP_HOME}/.rubocop.yml
COPY .rubocop_todo.yml ${APP_HOME}/.rubocop_todo.yml
COPY knapsack_rspec_report.json ${APP_HOME}/knapsack_rspec_report.json

COPY .rspec ${APP_HOME}/.rspec
COPY spec ${APP_HOME}/spec
