# Coffeelint [![Build Status](https://travis-ci.org/zmbush/coffeelint-ruby.svg?branch=master)](https://travis-ci.org/zmbush/coffeelint-ruby) [![Gem Version](https://badge.fury.io/rb/coffeelint.png)](http://badge.fury.io/rb/coffeelint)

Using coffeelint version: v1.11.0

Coffeelint is a set of simple ruby bindings for [coffeelint](https://github.com/clutchski/coffeelint).

## Install the [Gem](https://rubygems.org/gems/coffeelint)

Add this line to your application's Gemfile:

    gem 'coffeelint'

Or for the most up to date version:

    gem 'coffeelint', :git => 'git://github.com/zmbush/coffeelint-ruby.git', :submodules => true

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install coffeelint

## Usage

There are a few different uses of coffeelint.

```ruby
lint_report = Coffeelint.lint(coffeescript source code, [config options])
lint_report = Coffeelint.lint_file(filename of coffeescript source, [config_options])
lint_reports = Coffeelint.lint_dir(directory, [config_options])
Coffeelint.lint_dir(directory, [config_options]) do |filename, lint_report|
    puts filename
    puts lint_report
    Coffeelint.display_test_results(filename, lint_report)
end
Coffeelint.run_test(filename of coffeescript source, [config_options]) # Run tests and print pretty results (return true/false)
Coffeelint.run_test_suite(directory, [config_options]) # Runs a pretty report recursively for a directory (returns/exits with number of errors if any or 0)
```

### Config Options

The coffeelint gem takes the same config options as coffeelint. The only
addition is the config_file parameter. If you call coffeelint like:

```ruby
Coffeelint.run_test_suite(directory, :config_file => 'coffeelint_config.json')
```

Then it will load the config options from that file.

Alternatively you can create a config file in your project, coffeelint will load these by default:

* coffeelint.json
* .coffeelint.json
* config/coffeelint.json
* config/.coffeelint.json

To use a local version of coffeelint instead of the one bundled with the gem, You can set the path with `Coffeelint.set_path(/path/to/coffeelint.js)`

Additionally, if you are using rails you also get the rake task:

    rake coffeelint

Which will run the test on any *.coffee file in your `app` or `spec` directories

Finally, there is a command line utility that allows you to run standalone tests:

    coffeelint.rb <filename>
    coffeelint.rb -r <directory>
    coffeelint.rb -f <config.json> [-r] <fname-or-directory>

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Bundler needs a compiled coffeelint present which you can get by running

```
rake prepare
```
