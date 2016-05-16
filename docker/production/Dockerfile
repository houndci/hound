FROM quay.io/netguru/ng-ruby:2.3.1

# this app uses passenger
RUN /opt/passenger/install
# this app uses nodejs for assets precompilation
RUN /opt/node/install

RUN apt-get update && apt-get install -y libpq-dev

ENV APP_HOME /var/www/app
ENV RAILS_ENV=production
ENV RACK_ENV=production
ENV REDIS_URL=redis://redis:6379/0

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN bundle install --jobs=8 --retry=3  --without development test --deployment

ADD . $APP_HOME/
ADD docker/production/entrypoint.sh /entrypoint.sh

ADD docker/staging/service/resque-low /etc/service/resque-low/run
ADD docker/staging/service/resque-medium /etc/service/resque-medium/run
ADD docker/staging/service/resque-high /etc/service/resque-high/run
ADD docker/staging/service/resque-scheduler /etc/service/resque-scheduler/run

EXPOSE 3000

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/sbin/my_init"]
