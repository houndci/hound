FROM quay.io/netguru/ng-ruby:2.3.1

## Update Nodejs & NPM
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash - && \
  apt-get install -y nodejs

# install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb http://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y yarn

# this app uses passenger
RUN /opt/passenger/install

RUN apt-get update && apt-get install -y libpq-dev

ENV APP_HOME /var/www/app
ENV RAILS_ENV=staging
ENV RACK_ENV=staging
ENV REDIS_URL=redis://redis:6379/0
ENV NODE_ENV=production

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN bundle install --jobs=8 --retry=3  --without development test --deployment

ADD package.json $APP_HOME/
ADD yarn.lock $APP_HOME/
RUN yarn --no-emoji --no-progress --non-interactive

ADD . $APP_HOME/
ADD docker/staging/entrypoint.sh /entrypoint.sh

ADD docker/staging/service/resque-low /etc/service/resque-low/run
ADD docker/staging/service/resque-medium /etc/service/resque-medium/run
ADD docker/staging/service/resque-high /etc/service/resque-high/run
ADD docker/staging/service/resque-scheduler /etc/service/resque-scheduler/run

EXPOSE 3000

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/sbin/my_init"]
