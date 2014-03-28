# Hound

Take care of pesky code reviews with a trusty [Hound](http://houndci.com). Hound
reviews GitHub pull requests for style guide violations.
[View the style guide &rarr;](https://github.com/thoughtbot/guides)

# Development

To run your development environment:

1. Run `foreman start`
2. Authenticate with the GitHub app

### "Halp, I get a GitHub 404 error when I try to OAuth with GitHub locally!"

Don't Panic. You need to register the local Hound App with GitHub:

1. Log into GitHub and go to the Application Settings under Account settings:
   https://github.com/settings/applications
2. Under the Developer Applications panel - Click on "Register new application"
3. Fill in the application details (use a different port number if needed):
  * Application Name: HoundCI (Dev)
  * Homepage URL: http://localhost:5000
  * Authorization Callback URL: http://localhost:5000
4. After the Hound Dev app, a screen with a `Client ID` and `Client Secret`
   token should appear.
5. Add the `Client ID` and `Client Secret` to a `.env` in your local Hound
   Project:

   ```bash
    export GITHUB_CLIENT_ID=#client_id_token_here
    export GITHUB_CLIENT_SECRET=#client_secret_token_here
   ```

6. Restart your rails server with `foreman`

  ```bash
  $ foreman start
  ```
