# jshintrb
[![Build Status](https://secure.travis-ci.org/stereobooster/jshintrb.png?branch=master)](http://travis-ci.org/stereobooster/jshintrb)

Ruby wrapper for [JSHint](https://github.com/jshint/jshint/). The main difference from [jshint](https://github.com/liquid/jshint_on_rails) it does not depend on Java. Instead it uses [ExecJS](https://github.com/sstephenson/execjs).

## Installation

`jshintrb` is available as ruby gem.

    $ gem install jshintrb

Ensure that your environment has a JavaScript interpreter supported by [ExecJS](https://github.com/sstephenson/execjs). Usually, installing `therubyracer` gem is the best alternative.

## Usage

```ruby
require 'jshintrb'

Jshintrb.lint(File.read("source.js"))
# => array of warnings

Jshintrb.report(File.read("source.js"))
# => string
```

Or you can use it with rake

```ruby
require "jshintrb/jshinttask"
Jshintrb::JshintTask.new :jshint do |t|
  t.pattern = 'javascript/**/*.js'
  t.options = :defaults
end
```

When initializing `Jshintrb`, you can pass options

```ruby
Jshintrb::Lint.new(:undef => true).lint(source)
# Or
Jshintrb.lint(source, :undef => true)
```

[List of all available options](http://www.jshint.com/docs/options/)

If you pass `:defaults` as option, it is the same as if you pass following

```
{
  :bitwise => true,
  :curly => true,
  :eqeqeq => true,
  :forin => true,
  :immed => true,
  :latedef => true,
  :newcap => true,
  :noarg => true,
  :noempty => true,
  :nonew => true,
  :plusplus => true,
  :regexp => true,
  :undef => true,
  :strict => true,
  :trailing => true,
  :browser => true
}
```

If you pass `:jshintrc` as option, `.jshintrc` file is loaded as option.

## TODO

 - add more tests
 - add color reporter. Maybe [colorize](https://github.com/fazibear/colorize)
 - add cli. Support same options as [jshint/node-jshint](https://github.com/jshint/node-jshint/blob/master/lib/cli.js) 
