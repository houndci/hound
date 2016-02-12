# Contributing

First, thank you for contributing!

We love pull requests from everyone. By participating in this project, you
agree to abide by the thoughtbot [code of conduct].

[code of conduct]: https://thoughtbot.com/open-source-code-of-conduct

Here are a few technical guidelines to follow:

1. Open an [issue][issues] to discuss a new feature.
1. Write tests.
1. Make sure the entire test suite passes locally and on CI.
1. Open a Pull Request.
1. [Squash your commits][squash] after receiving feedback.
1. Party!

[issues]: https://github.com/houndci/hound/issues
[squash]: https://github.com/thoughtbot/guides/tree/master/protocol/git#write-a-feature

## Configure Hound on Your Local Development Environment

1. After cloning the repository, run the setup script

    `./bin/setup`

    **NOTE:** If you don't need Hound to communicate with your local machine, you may skip steps 3-6.
    Designers, you don't need ngrok for the purpose of making css changes and running the app locally.

1. Make sure that postgres, and redis, are both installed and running locally.

1. Ngrok allows GitHub to make requests via webhook to start a build. Sign up
for a free [ngrok] account and create a `~/.ngrok` file with the following:

    `auth_token: <your-token>`

1. Launch ngrok with a custom subdomain on port 5000.

    `ngrok -subdomain=<your-initials>-hound 5000`

1. Set the `HOST` variable in your `.env.local` to your ngrok host, e.g.
   `<your-initials>.ngrok.com`.

1. Change `ENABLE_HTTPS` to 'yes' in the `.env.local` file.

1. Log into your GitHub account and go to your
   [developer application settings].

1. Under the Developer applications panel - Click on "Register new
   application" and fill in the details:

    * Application Name: Hound Development
    * Homepage URL: `https://<your-initials>-hound.ngrok.com`
      **NOTE:** If you did not set up ngrok, use `http://localhost:5000`
    * Authorization Callback URL: `https://<your-initials>-hound.ngrok.com`
      **NOTE:** If you did not set up ngrok, use `http://localhost:5000`

      **NOTE:** If you did not set up ngrok, skip to the last step.

1. On the confirmation screen, copy the `Client ID` and `Client Secret` to
   `GITHUB_CLIENT_ID` and `GITHUB_CLIENT_SECRET` in the `.env.local` file.

1. On the [personal access token] page, click "Generate new token" and fill
   in token details:

    * Token description: Hound Development
    * Select scopes: `repo` and `user:email`

1. On the confirmation screen, copy the generated token to `HOUND_GITHUB_TOKEN`
   in the `.env.local` file. Also update `HOUND_GITHUB_USERNAME` to be your username.

1. Run `foreman start`. Foreman will start the web server and
   the resque background job queue. NOTE: `rails server` will not load the
   appropriate environment variables and you'll get a "Missing `secret_key_base`
   for 'development' environment" error.

1. Open `https://<your-initials>-hound.ngrok.com` in a browser.

[ngrok]: https://ngrok.com
[personal access token]: https://github.com/settings/tokens
[developer application settings]: https://github.com/settings/developers

## Testing

1. Set up your `development` environment as per above.
1. Run `rake` to execute the full test suite.

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

## Linters

To better understand the architecture of Hound, here is a list of the linters
and services being used, and the default configuration for each linter.

1. Ruby
 * [RuboCop](https://github.com/bbatsov/rubocop)
 * [config](https://raw.githubusercontent.com/houndci/hound/master/config/style_guides/ruby.yml)

1. CoffeeScript
 * [CoffeeLint](https://github.com/clutchski/coffeelint)
 * [config](https://raw.githubusercontent.com/houndci/hound/master/config/style_guides/coffeescript.json)

1. JavaScript (JSHint)
 * [houndci/jshint](https://github.com/houndci/jshint)
 * [config](https://raw.githubusercontent.com/houndci/jshint/master/config/.jshintrc)

1. SCSS
 * [houndci/scss](https://github.com/houndci/scss)
 * [config](https://raw.githubusercontent.com/houndci/scss/master/config/default.yml)

1. Haml
 * [haml-lint](https://github.com/brigade/haml-lint)
 * [config](https://raw.githubusercontent.com/houndci/hound/master/config/style_guides/haml.yml)

1. Go
 * [houndci/go](https://github.com/houndci/go)

1. Markdown (beta)
 * [houndci/remark](https://github.com/houndci/remark)
 * [config](https://github.com/wooorm/remark-lint#rules)

1. Swift (beta)
 * [houndci/swift](https://github.com/houndci/swift)
 * [config](https://github.com/houndci/swift/blob/master/config/default.yml)

### Writing a Linter

Linters check code snippets for style violations. They operate by polling a
Resque queue.

Linter jobs are created with the following arguments:

* `config` - The configuration for the linter. This will be linter specific.
* `content` - The source code to check for violations.
* `filename` - The name of the source file for the code snippet. This should be
  passed through to the outbound queue.
* `commit_sha` - The git commit SHA of the code snippet. This should be passed
  through to the outbound queue.
* `pull_request_number` - The GitHub pull request number. This should be passed
  through to the outbound queue.
* `patch` - The patch content from GitHub for the file being reviewed. This
  should be passed through to the outbound queue.

Once linting is complete, resulting violations should be posted to the outbound
"CompletedFileReviewJob" queue:

* `violations` - An array of violation objects. Each violation requires the
  following:
  * `line` - The line number where the violation occurred.
  * `message` - A message describing the violation. This will be the contents
    of the Pull Request comment.
* `filename` - The name of the source file for the code snippet. This is
  provided by the inbound queue.
* `commit_sha` - The git commit SHA of the code snippet. This is provided by the
  inbound queue.
* `pull_request_number` - The GitHub pull request number. This is provided by the
  inbound queue.
* `patch` - The patch content from GitHub for the file being reviewed. This is
  provided by the inbound queue.

If the given `config` is invalid, the invalid file should be posted to the
outbound `ReportInvalidConfigJob` queue:

* `commit_sha` - The git commit SHA of the code snippet. This is provided by the
  inbound queue.
* `linter_name` - The name of the linter that received an invalid config file.
* `pull_request_number` - The GitHub pull request number. This is provided by
  the inbound queue.

## Contributor License Agreement

If you submit a Contribution to this application's source code, you hereby grant
to thoughtbot, inc. a worldwide, royalty-free, exclusive, perpetual and
irrevocable license, with the right to grant or transfer an unlimited number of
non-exclusive licenses or sublicenses to third parties, under the Copyright
covering the Contribution to use the Contribution by all means, including but
not limited to:

* to publish the Contribution,
* to modify the Contribution, to prepare Derivative Works based upon or
  containing the Contribution and to combine the Contribution with other
  software code,
* to reproduce the Contribution in original or modified form,
* to distribute, to make the Contribution available to the public, display and
  publicly perform the Contribution in original or modified form.
