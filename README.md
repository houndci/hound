Hound
=====

[![Build Status](https://travis-ci.org/thoughtbot/hound.svg?branch=master)](http://travis-ci.org/thoughtbot/hound?branch=master)
[![Code Climate](https://codeclimate.com/github/thoughtbot/hound.png)](https://codeclimate.com/github/thoughtbot/hound)

Take care of pesky code reviews with a trusty [Hound](http://houndci.com).

Hound reviews GitHub pull requests for style guide violations. [View the style
guide &rarr;](https://github.com/thoughtbot/guides/tree/master/style)

## Configure Hound on Your Local Development Environment

1. After cloning the repository, run the setup script `./bin/setup`
2. Log into your GitHub account and go to the
   [Application Settings under Account settings](https://github.com/settings/applications).
3. Under the GitHub Developer Applications panel - Click on "Register new
   application"
4. Fill in the application details:
  * Application Name: Hound Development
  * Homepage URL: http://localhost:5000
  * Authorization Callback URL: http://localhost:5000
5. On the confirmation screen, copy the `Client ID` and `Client Secret` to
   `.env`. Note the setup script copies `.sample.env` to `.env` for you, if the
   file does not exist.
6. Generate the [Stripe tokens] and copy them into your `.env` file. Put the
   'Test Secret Key' as the value for `STRIPE_API_KEY` and 'Test Publishable
   Key' as the value for `STRIPE_PUBLISHABLE_KEY`.
7. Create a Stripe plan called "private" for your development environment
   https://dashboard.stripe.com/test/plans
> ID: "private"
> Name: "private"

8. Run `foreman start`. Foreman will start the web server, `redis-server`, and
   the resque background job queue. NOTE: `rails server` will not load the
   appropriate environment variables and you'll get a "Missing `secret_key_base`
   for 'development' environment" error.

[Stripe tokens]: https://manage.stripe.com/account/apikeys

Testing
-----------

1. Set up your `development` environment as per above.
2. Run `rake` to execute the full test suite.

#### Stripe

To test Stripe payments on staging use this fake credit card number.

<table>
  <thead>
    <tr>
      <th>Card</th>
      <th>Number</th>
      <th>Expiration</th>
      <th>CVV</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Visa</td>
      <td>4242424242424242</td>
      <td>Any future date</td>
      <td>Any 3 digits</td>
    </tr>
  </tbody>
</table>

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
