# BUILD STAGE #
FROM ruby:2.6.6 AS build
MAINTAINER dxw <rails@dxw.com>

ENV INSTALL_PATH /srv/app
ARG RAILS_ENV
ENV RAILS_ENV=${RAILS_ENV:-production}
ENV RACK_ENV=${RAILS_ENV:-production}

WORKDIR $INSTALL_PATH

RUN apt-get update && apt-get install -qq -y \
  build-essential \
  libpq-dev \
  --fix-missing --no-install-recommends
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
        && apt-get install -y nodejs

COPY package.json ./package.json
COPY package-lock.json ./package-lock.json

RUN npm install

COPY Gemfile* ./
RUN gem install bundler:2.1.4 --no-document

ARG BUNDLE_EXTRA_GEM_GROUPS
ENV BUNDLE_GEM_GROUPS=${BUNDLE_EXTRA_GEM_GROUPS:-"production"}
RUN bundle config set no-cache "true"
RUN bundle config set with $BUNDLE_GEM_GROUPS
RUN bundle install --no-binstubs --retry=3 --jobs=4

COPY . .

# RELEASE STAGE #
FROM ruby:2.6.6 AS release

ENV INSTALL_PATH /srv/app
ARG RAILS_ENV
ENV RAILS_ENV=${RAILS_ENV:-production}
ENV RACK_ENV=${RAILS_ENV:-production}

WORKDIR $INSTALL_PATH

RUN gem install bundler:2.1.4 --no-document

COPY --from=build /usr/local/bundle/ /usr/local/bundle/
COPY --from=build $INSTALL_PATH $INSTALL_PATH

# Compiling assets requires a key to exist: https://github.com/rails/rails/issues/32947
RUN if [ "$RAILS_ENV" = "production" ]; then \
      RAILS_ENV=production SECRET_KEY_BASE="key" bundle exec rake assets:precompile; \
    fi

COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server"]
