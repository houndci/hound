Thanks for taking the time to contribute to jquery-rails! Please
take a moment to read the following brief guidelines to help streamline
the merging process.

## Updating jQuery

If the jquery or jquery-ui scripts are outdated (i.e. maybe a new version of jquery was released yesterday), feel free to open an issue and prod us to get that thing updated. However, for security reasons, we won't be accepting pull requests with updated jquery or jquery-ui scripts.

## Changes to jquery_ujs.js

**If it's an issue pertaining to the jquery-ujs javascript, please
report it to the [rails/jquery-ujs project](https://github.com/rails/jquery-ujs/issues).**

## Tests

This is a gem that simply includes jQuery and jQuery UJS into the Rails
asset pipeline. The asset pipeline functionality is well tested within the
Rails framework. And jQuery and jQuery UJS each have their own extensive
test suites. Thus, there's not a lot to actually test here.

That being said, we do have a few integration-level tests to make sure
everything is being included and basic UJS functionality works within a
sample Rails app.

If you're making changes to the actual gem, run the tests as follows:

1. Checkout the demo Rails app: `git clone git://github.com/JangoSteve/Rails-jQuery-Demo.git`

2. Install the gems: `bundle install`

3. Change the jquery-rails gem in the Gemfile to use your local
version of the gem with your updates: `gem 'rspec-rails', :path => '../path/to/jquery-rails'`

4. Update your bundled jquery-rails gem: `bundle update jquery-rails`

5. Run the tests: `bundle exec rspec spec/`
