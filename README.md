Hound
=====

[![Build Status](https://travis-ci.org/thoughtbot/hound.svg?branch=master)](http://travis-ci.org/thoughtbot/hound?branch=master)
[![Code Climate](https://codeclimate.com/github/thoughtbot/hound.png)](https://codeclimate.com/github/thoughtbot/hound)

Take care of pesky code reviews with a trusty [Hound](http://houndci.com).

Hound reviews GitHub pull requests for style guide violations. [View the style
guide &rarr;](https://github.com/thoughtbot/guides/tree/master/style)

Development
-----------

1. Rename `.sample.env` to `.env`
2. Log into GitHub and go to the Application Settings under Account settings:
   https://github.com/settings/applications
3. Under the Developer Applications panel - Click on "Register new application"
4. Fill in the application details:
  * Application Name: Hound Development
  * Homepage URL: http://localhost:5000
  * Authorization Callback URL: http://localhost:5000
4. After the Hound Dev app, a screen with a `Client ID` and `Client Secret`
   token should appear.
5. Add the `Client ID` and `Client Secret` to `.env`

 ```bash
  GITHUB_CLIENT_ID=#client_id_token_here
  GITHUB_CLIENT_SECRET=#client_secret_token_here
 ```

6. Run the setup script `./bin/setup`
7. Run `foreman start`
8. Run `redis-server`

Testing
-----------

1. Set up your `development` environment as per above.
2. Run `rake` to execute the full test suite.

Contributing
------------

First, thank you for contributing!

Here a few guidelines to follow:

1. Write tests
2. Make sure the entire test suite passes locally and on Travis CI
3. Open a pull request on GitHub
4. [Squash your commits](https://github.com/thoughtbot/guides/tree/master/protocol/git#write-a-feature) after receiving feedback

There a couple areas we would like to concentrate on.

1. Add support for JavaScript
2. Add support for CSS and Sass
3. Write [style guides](app/models/style_guide) that don't currently exist and
   would enforce the
   [thoughtbot style guide](https://github.com/thoughtbot/guides).
