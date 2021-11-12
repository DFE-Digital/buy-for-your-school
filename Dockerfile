# ------------------------------------------------------------------------------
# Base
# ------------------------------------------------------------------------------
FROM ruby:3.0.1 as base

RUN apt-get update && apt-get install -qq -y \
    build-essential \
    libpq-dev \
    --fix-missing --no-install-recommends

RUN wget -q https://github.com/jgm/pandoc/releases/download/2.14.2/pandoc-2.14.2-1-amd64.deb; \
    apt-get install ./pandoc-2.14.2-1-amd64.deb; \
    rm pandoc-2.14.2-1-amd64.deb

RUN apt-get install -qq -y \
    texlive \
    texlive-generic-extra \
    --fix-missing --no-install-recommends


# ------------------------------------------------------------------------------
# Assets
# ------------------------------------------------------------------------------
FROM node:alpine as assets

ENV NODE_ENV ${NODE_ENV:-production}

RUN mkdir /deps

WORKDIR /deps

COPY package-lock.json /deps/package-lock.json
COPY package.json /deps/package.json

RUN npm install

# ------------------------------------------------------------------------------
# Production Stage
# ------------------------------------------------------------------------------
FROM base AS app

ENV APP_HOME /srv/app
ENV RAILS_ENV ${RAILS_ENV:-production}

RUN mkdir -p ${APP_HOME}/{log,tmp/pids,vendor}

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

COPY --from=assets /deps/node_modules /srv/node_modules

RUN cp -R /srv/node_modules $APP_HOME/node_modules
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

RUN apt-get install -qq -y shellcheck wait-for-it

RUN curl -L https://codeclimate.com/downloads/test-reporter/test-reporter-latest-linux-amd64 > /usr/bin/cc-test-reporter
RUN chmod +x /usr/bin/cc-test-reporter

COPY .rubocop.yml ${APP_HOME}/.rubocop.yml
COPY .rubocop_todo.yml ${APP_HOME}/.rubocop_todo.yml

COPY .rspec ${APP_HOME}/.rspec
COPY spec ${APP_HOME}/spec
