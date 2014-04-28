Hound
=====

[![Build Status](https://secure.travis-ci.org/thoughtbot/hound.png)](http://travis-ci.org/thoughtbot/hound?branch=master)
[![Code Climate](https://codeclimate.com/github/thoughtbot/hound.png)](https://codeclimate.com/github/thoughtbot/hound)

Take care of pesky code reviews with a trusty [Hound](http://houndci.com).

Hound reviews GitHub pull requests for style guide violations. [View the style
guide &rarr;](https://github.com/thoughtbot/guides)

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

6. Run `foreman start`
