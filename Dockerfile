FROM ruby:2.3.1
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev libpcre3-dev libdumbnet-dev libpcap-dev qt4-qmake qt5-qmake qt5-default libqt5webkit5-dev libpq-dev ruby-dev make libmysqlclient-dev
RUN mkdir /myapp
WORKDIR /myapp
RUN gem install bundler --version=1.12.4
ADD Gemfile /myapp/Gemfile
ADD Gemfile.lock /myapp/Gemfile.lock
RUN bundle install
ADD . /myapp
