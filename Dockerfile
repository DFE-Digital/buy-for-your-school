FROM ruby:2.6.6 as release
MAINTAINER dxw <rails@dxw.com>
RUN apt-get update && apt-get install -qq -y \
  build-essential \
  libpq-dev \
  --fix-missing --no-install-recommends
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
        && apt-get install -y nodejs

ENV INSTALL_PATH /srv/app
RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH

# set rails environment
ARG RAILS_ENV
ENV RAILS_ENV=${RAILS_ENV:-production}
ENV RACK_ENV=${RAILS_ENV:-production}

COPY package.json $INSTALL_PATH/package.json
COPY package-lock.json $INSTALL_PATH/package-lock.json

RUN npm install

COPY Gemfile $INSTALL_PATH/Gemfile
COPY Gemfile.lock $INSTALL_PATH/Gemfile.lock

RUN gem update --system
RUN gem install bundler

# bundle ruby gems based on the current environment, default to production
RUN echo $RAILS_ENV
RUN if [ "$RAILS_ENV" = "production" ]; then \
      bundle install --without development test --retry 10; \
    else \
      bundle install --retry 10; \
    fi

COPY . $INSTALL_PATH

# Compiling assets requires a key to exist: https://github.com/rails/rails/issues/32947
RUN if [ "$RAILS_ENV" = "production" ]; then \
      RAILS_ENV=production SECRET_KEY_BASE="key" bundle exec rake assets:precompile; \
    fi


# db setup
COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 3000

CMD ["rails", "server"]
