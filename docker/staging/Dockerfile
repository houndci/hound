FROM quay.io/netguru/ng-ruby:2.3.0

# this app uses passenger
RUN /opt/passenger/install
# this app uses nodejs for assets precompilation
RUN /opt/node/install

ENV APP_HOME /var/www/app
ENV RAILS_ENV=staging
ENV REDIS_URL=redis://redis:6379/0

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN bundle install --jobs=8 --retry=3  --without development test --deployment

ADD . $APP_HOME/
ADD docker/staging/entrypoint.sh /entrypoint.sh

ADD docker/staging/service/resque /etc/service/resque/run

EXPOSE 3000

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/sbin/my_init"]
