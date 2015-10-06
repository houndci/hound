# resque-sentry

A Resque failure backend that sends errors to [Sentry](https://getsentry.com).

### Installation

```console
$ gem install resque-sentry
```

### Usage

Add the following to an initializer:

```ruby
require 'resque-sentry'

# [optional] custom logger value to use when sending to Sentry (default is 'root')
Resque::Failure::Sentry.logger = "resque"

Resque::Failure::Multiple.classes = [Resque::Failure::Redis, Resque::Failure::Sentry]
Resque::Failure.backend = Resque::Failure::Multiple
```

