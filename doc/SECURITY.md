Security
========

This document is intended to help our customers'
security, risk, compliance, or developer teams
evaluate what we do with our customers' code and data.

Because [Hound is open source][oss],
in this document we refer to portions of the application code and its dependent
libraries, frameworks, and programming languages.

[oss]: https://github.com/houndci/hound

Vulnerability Reporting
-----------------------

For security inquiries or vulnerability reports, please email
<hello@houndci.com>.

Hound Group
-----------

Hound is operated by Hound Group LLC,
a [California limited liability company][sos].

[sos]: https://businesssearch.sos.ca.gov/CBS/SearchResults?SearchType=NUMBER&SearchCriteria=201806410516

A small team within Hound Group LLC is responsible for Hound.
We can't afford to hire a third party security company to audit Hound,
but the codebase is open source.
We believe that transparency and this document can help keep Hound
as secure as possible.

What happens when you authenticate your GitHub account
------------------------------------------------------

Hound uses the [OmniAuth GitHub] Ruby gem to
authenticate your GitHub account using [GitHub's OAuth2 flow][gh-oauth]
and provide Hound with a GitHub token.

[OmniAuth GitHub]: https://github.com/intridea/omniauth-github
[gh-oauth]: https://developer.github.com/v3/oauth/

Using OAuth2 means we do not access your GitHub password
and that you can revoke our access at any time.

Your GitHub token is needed in order to fetch file content, comments, repo
information and update Pull Request status. This token is encrypted and encoded
using `ActiveSupport::MessageEncryptor` and stored in our Postgres database
on Heroku.
`ActiveSupport::MessageEncryptor` [uses `aes-256-cbc`][message-encryptor]
for encryption and base64 for encoding.

To browse the portions of the codebase related to authentication,
try `grep`ing for the following terms:

```bash
grep -R omniauth app
grep -R token app
```

[message-encryptor]: https://github.com/rails/rails/blob/2af7338bdf32790a28e388a99dada84db0af1b5f/activesupport/lib/active_support/message_encryptor.rb#L35

What happens when Hound refreshes your GitHub repositories
----------------------------------------------------------

We pass your GitHub token to our [Ruby on Rails] app
(the app whose source code you are reading right now),
which runs on [Heroku].

Our app passes your GitHub token from memory in
[`RepoSyncsController`] to our [Redis] database,
as part of scheduling a background job ([`RepoSynchronizationJob`]).
The Redis database is hosted by [Heroku Redis Addon].

[`RepoSyncsController`]: ../app/controllers/repo_syncs_controller.rb
[`RepoSynchronizationJob`]: ../app/jobs/repo_synchronization_job.rb
[Redis]: http://redis.io/
[Heroku Redis Addon]: https://elements.heroku.com/addons/heroku-redis

As part of this process,
we temporarily store your GitHub token in the Redis database
when enqueueing a Sidekiq job to fetch a list of your repos.

[Ruby on Rails]: http://rubyonrails.org
[Heroku]: https://www.heroku.com

Heroku is a "Platform as a Service",
which runs on Amazon Web Services' "Infrastructure as a Service."
Read [Heroku's security policy][aws] for information about their
security assessments, compliance, penetration testing,
environmental safeguards, network security, and more.

[aws]: https://www.heroku.com/policy/security

Refreshing your GitHub repos allows you to later enable Hound on those repos.

What happens when you enable Hound on your GitHub repository
------------------------------------------------------------

When you click the "Activate" button in the Hound web interface
for one of your private GitHub repositories,
we send your GitHub token from the web browser's session
to the Ruby process on Heroku
through the [`SubscriptionsController`].

[`SubscriptionsController`]: ../app/controllers/subscriptions_controller.rb

We use your GitHub token to add the [@houndci-bot] GitHub user to your repo
via the [GitHub collaborator API][api1]. @houndci-bot is added as a collaborator
to the enabled repository. This is necessary in order for us to be able to make
comments as @houndci-bot and to update pull request statuses, or to read file
contents if no other valid token is found for the enabled repository.

[@houndci-bot]: https://github.com/houndci-bot
[api1]: https://developer.github.com/v3/repos/collaborators/#add-collaborator

We also create a webhook on your repository via the [GitHub webhook API][api2].
This allows us to receive pull request notifications.

[api2]: https://developer.github.com/v3/repos/hooks/#create-a-hook

To browse the portions of the codebase related to enabling repos,
try `grep`ing for the following terms:

```bash
grep -R add_hound_to_repo app
grep -R create_webhook app
```

What happens when you pay for Hound
-----------------------------------

When you enable a private GitHub repo with Hound,
we use [Stripe Checkout] to collect and send your credit card information
to [Stripe], a payment processor.

Your credit card data is sent directly from your web browser to Stripe
over a TLS connection.
It is never sent through Hound's Ruby processes
and we never store your credit card information.

[Stripe Checkout]: https://stripe.com/checkout
[Stripe]: https://stripe.com

We receive a token from Stripe that represents a unique reference to your
credit card within the context of Hound's application.
We store that token in our Postgres database.

Read [Stripe's security policy] for information about PCI compliance,
TLS, encryption, and more.

[Stripe's security policy]: https://stripe.com/help/security

To browse the portions of the codebase related to payment,
try `grep`ing for the following terms:

```bash
grep -R card_token app
grep -R stripe_customer app
```

What happens when we receive a pull request notification
--------------------------------------------------------

When you open a pull request on your GitHub repo,
or push a new commit to the branch for that pull request,
Hound receives the payload in the [`BuildsController`].
This payload doesn't contain any code.
It contains metadata about the pull request such as repo, user, and commit.

[`BuildsController`]: ../app/controllers/builds_controller.rb

The payload is stored in Redis so that [`StartBuild`] can prepare configuration
and file contents for each enabled linter, then send the files off for review
via Sidekiq (uses Redis) to the `linters` service.

[`StartBuild`]: ../app/services/start_build.rb

`StartBuild` pulls the payload out of Redis and into Ruby memory on Heroku.
Using the information from the payload, it makes a HTTP requests to GitHub's
REST API to get the pull request's patch and file contents.
Hound never fetches a complete version of your codebase.

In Ruby memory,
`StartBuild` passes your pull request's contents to [`ReviewFiles`],
which loops through the changed files and delegates to the appropriate
[`Linter`] Ruby classes based on file extension (`.rb`, `.js`, etc.).

[`ReviewFiles`]: ../app/services/review_files.rb
[`Linter`]: ../app/models/linter/

The `Linter` classes schedule a job on a queue with all the necessary
information (configuration file, file contents to review, and metadata).
The job is then picked up by `linters` service, which will actually do the
linting using specific open source libraries, like:

* Ruby: [RuboCop](https://github.com/bbatsov/rubocop)
* CoffeeScript: [CoffeeLint](http://www.coffeelint.org/)
* JavaScript:
  * [JSHint](https://github.com/jshint/jshint)
  * [ESLint](https://github.com/eslint/eslint)
* SCSS: [SCSS-Lint](https://github.com/brigade/scss-lint)
* Go: [golint](https://github.com/golang/lint)

Those libraries find code violations
and pass them back up through Sidekiq for [`CompleteBuild`] to finish.
The violations are collected in the [`Violation`] classes, and also stored in
our PostgreSQL database. [`SubmitReview`] fetches them, converts them to a
format that fits GitHub comments, and submits the PR review to GitHub,
to comment about the violations on the pull request.

[`CompleteBuild`]: ../app/services/complete_build.rb
[`SubmitReview`]: ../app/services/submit_review.rb
[`Violation`]: ../app/models/violation.rb
[`Commenter`]: ../app/services/commenter.rb
[comment-api]: https://developer.github.com/v3/pulls/comments/

`CompleteFileReview` saves each violation, the line number, and patch position,
in the `violations` table of our Postgres database.
We store single lines of your code in Postgres, which is encrypted and encoded
similar to tokens using `ActiveSupport::MessageEncryptor`.
We also store the contents of the files to review temporarily in Sidekiq, but
that is removed as soon as the job is processed.

To browse the portions of the codebase related to
receiving and processing pull request notifications,
try `grep`ing for the following terms:

```bash
grep -R ReviewFiles app
grep -R CompleteFileReview app
grep -R SubmitReview app
```

Employee access
---------------

All Hound Group employees have access to change Hound's source code
(the repo you're reading right now, which is open source)
and to push it to GitHub.

All Hound Group employees have access to
Hound's staging and production Heroku applications and databases.
They can deploy new code, or read and write to the databases.

What you can do to make your Hound use safer
--------------------------------------------

Use environment variables in your code
to [separate code from configuration][12factor].

[12factor]: http://12factor.net/config

Third-party auditing
--------------------

We can't afford to hire a third party security company to audit Hound,
but the codebase is open source.
We believe that transparency and this document can help keep Hound
as secure as possible.
