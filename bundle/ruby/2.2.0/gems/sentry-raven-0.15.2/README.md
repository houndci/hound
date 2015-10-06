# Raven-Ruby

[![Gem Version](https://img.shields.io/gem/v/sentry-raven.svg)](https://rubygems.org/gems/sentry-raven)
[![Build Status](https://img.shields.io/travis/getsentry/raven-ruby/master.svg)](https://travis-ci.org/getsentry/raven-ruby)

A client and integration layer for the [Sentry](https://github.com/getsentry/sentry) error reporting API.

## Requirements

We test on Ruby MRI 1.8.7/REE, 1.9.3, 2.0, 2.1 and 2.2. JRuby support is experimental - check TravisCI to see if the build is passing or failing.

## Getting Started
### Install
```ruby
gem "sentry-raven" #, :github => "getsentry/raven-ruby"
```
### Set SENTRY_DSN
```bash
# Set your SENTRY_DSN environment variable.
export SENTRY_DSN=http://public:secret@example.com/project-id
```
```ruby
# Or you can configure the client in the code (not recommended - keep your DSN secret!)
Raven.configure do |config|
  config.dsn = 'http://public:secret@example.com/project-id'
end
```
### Call
If you use Rails, you're already done - no more configuration required! Check [Integrations](https://github.com/getsentry/raven-ruby/wiki/Integrations) for more details on other gems Sentry integrates with automatically.

Otherwise, Raven supports two methods of capturing exceptions:
```ruby
Raven.capture do
  # capture any exceptions which happen during execution of this block
  1 / 0
end

begin
  1 / 0
rescue ZeroDivisionError => exception
  Raven.capture_exception(exception)
end
```

## More Information

Full documentation and more information on advanced configuration, sending more information, scrubbing sensitive data, and more can be found on [the wiki](https://github.com/getsentry/raven-ruby/wiki).

* [Documentation](https://github.com/getsentry/raven-ruby/wiki)
* [Bug Tracker](https://github.com/getsentry/raven-ruby/issues>)
* [Code](https://github.com/getsentry/raven-ruby>)
* [Mailing List](https://groups.google.com/group/getsentry>)
* [IRC](irc://irc.freenode.net/sentry>)  (irc.freenode.net, #sentry)
