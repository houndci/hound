# momentjs-rails

momentjs-rails wraps the [Moment.js](http://momentjs.com/) library in a rails engine for simple
use with the asset pipeline provided by Rails 3.1 and higher. The gem includes the development (non-minified)
source for ease of exploration. The asset pipeline will minify in production.

Moment.js is "a lightweight javascript date library for parsing, manipulating, and formatting dates."
Moment.js does not modify the native Date object. Rather, it creates a wrapper for it. Please see the
[documentation](http://momentjs.com/docs/) for details.

## Usage

Add the following to your gemfile:

    gem 'momentjs-rails'

Add the following directive to your Javascript manifest file (application.js):

    //= require moment

If you want to include a localization file, also add the following directive:

    //= require moment/<locale>.js

## Versioning

momentjs-rails 2.10.3 == Moment.js 2.10.3

Every attempt is made to mirror the currently shipping Momentum.js version number wherever possible.
The major, minor, and patch version numbers will always represent the Momentum.js version. Should a gem
bug be discovered, a 4th version identifier will be added and incremented.
