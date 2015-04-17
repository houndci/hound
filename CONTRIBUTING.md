# Contributing

First, thank you for contributing!

We love pull requests from everyone. By participating in this project, you
agree to abide by the thoughtbot [code of conduct].

[code of conduct]: https://thoughtbot.com/open-source-code-of-conduct

Here are a few technical guidelines to follow:

1. Open an [issue][issues] to discuss a new feature.
1. Write tests.
1. Make sure the entire test suite passes locally and on Travis CI.
1. Open a Pull Request.
1. [Squash your commits][squash] after receiving feedback.
1. Party!

[issues]: https://github.com/thoughtbot/hound/issues
[squash]: https://github.com/thoughtbot/guides/tree/master/protocol/git#write-a-feature

## Configure Hound on Your Local Development Environment

1. After cloning the repository, run the setup script

    `./bin/setup`

1. Sign up for a free [ngrok] account and create a `~/.ngrok` file with the
   following:

    `auth_token: <your-token>`

1. Launch ngrok with a custom subdomain on port 5000.

    `ngrok -subdomain=<your-initials>-hound 5000`

1. Set the `HOST` variable in your `.env` to your ngrok host, e.g.
   `<your-initials>.ngrok.com`.

1. Change `ENABLE_HTTPS` to 'yes' in the .env file.

1. Log into your GitHub account and go to your
   [application settings].

1. Under the Developer applications panel - Click on "Register new
   application" and fill in the details:

    * Application Name: Hound Development
    * Homepage URL: `https://<your-initials>-hound.ngrok.com`
    * Authorization Callback URL: `http://<your-initials>-hound.ngrok.com`

1. On the confirmation screen, copy the `Client ID` and `Client Secret` to
   `GITHUB_CLIENT_ID` and `GITHUB_CLIENT_SECRET` in the `.env` file.

1. Back on the [application settings] page, click "Generate new token" and fill
   in token details:

    * Token description: Hound Development
    * Select scopes: `repo` and `user:email`

1. On the confirmation screen, copy the generated token to `HOUND_GITHUB_TOKEN`
   in the `.env` file. Also update `HOUND_GITHUB_USERNAME` to be your username.

1. Run `foreman start`. Foreman will start the web server and
   the resque background job queue. NOTE: `rails server` will not load the
   appropriate environment variables and you'll get a "Missing `secret_key_base`
   for 'development' environment" error.

[ngrok]: https://ngrok.com
[application settings]: https://github.com/settings/applications

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
