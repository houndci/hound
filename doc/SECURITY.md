Security
========

This document is intended to help our customers'
security, risk, compliance, or developer teams
evaluate what we do with our customers' code and data.

Because [Hound is open source][oss],
in this document we refer to portions of the application code and its dependent
libraries, frameworks, and programming languages.

[oss]: https://github.com/thoughtbot/hound

Vulnerability Reporting
-----------------------

For security inquiries or vulnerability reports, please email
[security@thoughtbot.com](security@thoughtbot.com).
If you'd like, you can use our [PGP key] when reporting vulnerabilities.

[PGP key]: http://pgp.thoughtbot.com

thoughtbot
----------

Hound is operated by [thoughtbot, inc.], a [Massachusetts corporation][sec].

[thoughtbot, inc.]: http://thoughtbot.com
[sec]: http://corp.sec.state.ma.us/CorpWeb/CorpSearch/CorpSummary.aspx?FEIN=203438204

A small team within thoughtbot is responsible for Hound.
We can't afford to hire a third party security company to audit Hound,
but the codebase is open source.
We believe that transparency and this document can help keep Hound
as secure as possible.

What happens when you authenticate your GitHub account
------------------------------------------------------

Hound uses the [OmniAuth GitHub] Ruby gem to
authenticate your GitHub account using [GitHub's OAuth2 flow][gh-oauth].

[OmniAuth GitHub]: https://github.com/intridea/omniauth-github
[gh-oauth]: https://developer.github.com/v3/oauth/

Using OAuth2 means we do not access your GitHub password
and that you can revoke our access at any time.

We need this token in order to refresh your GitHub repositories with Hound,
which we do once, immediately after you authenticate your GitHub account.
Later, you can manually refresh your GitHub repositories with Hound at any time.

To browse the portions of the codebase related to authentication,
try `grep`ing for the following terms:

```bash
grep -R omniauth app
grep -R github_token app
```

What happens when Hound refreshes your GitHub repositories
----------------------------------------------------------

We pass your GitHub token to our [Ruby on Rails] app
(the app whose source code you are reading right now),
which runs on [Heroku].

We temporarily store your GitHub token in the Redis database
when enqueueing a Resque job
to fetch a list of your repos.

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

When you click the "toggle" switch in the Hound web interface
for one of your private GitHub repositories,
we send your GitHub token from the web browser's session
to the Ruby process on Heroku
through the [`SubscriptionsController`].

[`SubscriptionsController`]: ../app/controllers/subscriptions_controller.rb

Our Ruby process passes your GitHub token from memory in
[`RepoSynchronizationJob`] to our [Redis] database.
The database is hosted by [Redis to Go].

[`RepoSynchronizationJob`]: ../app/jobs/repo_synchronization_job.rb
[Redis]: http://redis.io/
[Redis to Go]: http://redistogo.com

We use your GitHub token to add the [@houndci] GitHub user to your repository
via the [GitHub collaborator API][api1]. @houndci will be added to a team that
has access to the enabled repository. If an existing team cannot be found, we'll
create a "Services" team with *push* access to the enabled repository. This is
necessary for @houndci to see pull requests, make comments, and update pull
request statuses.

[@houndci]: https://github.com/houndci
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

The payload is stored in Redis so that
[`BuildRunner`] can check style on it in a background job.

[`BuildRunner`]: ../app/services/build_runner.rb

`BuildRunner` pulls the payload out of Redis
and back into Ruby memory on Heroku.
Using the information from the payload,
it makes a new HTTP request to GitHub's API to get
the pull request's diff and file contents.
Hound never fetches a complete version of your codebase.

In Ruby memory,
`BuildRunner` passes your pull request's contents to [`StyleChecker`],
which loops through the changes files and delegates to the appropriate
[`StyleGuide`] Ruby classes based on file extension (`.rb`, `.js`, etc.).

[`StyleChecker`]: ../app/models/style_checker.rb
[`StyleChecker`]: ../app/models/style_guide

The `StyleGuide` classes wrap the language-specific open source libraries
that we use to check the style of the code in each pull request notification:

* Ruby: [RuboCop](https://github.com/bbatsov/rubocop)
* CoffeeScript: [CoffeeLint](http://www.coffeelint.org/)
* JavaScript: [JSHint](https://github.com/jshint/jshint/)

Those libraries find style violations
and pass them back up through `StyleGuide` and `BuildRunner`.
The violations are collected in the [`Violations`] class,
which is passed to [`Commenter`],
which uses the [GitHub commenting API][comment-api]
to comment about the violations on the pull request.

[`Violations`]: ../app/models/violations.rb
[`Commenter`]: ../app/services/commenter.rb
[comment-api]: https://developer.github.com/v3/pulls/comments/

`BuildRunner` also saves the violations,
the pull request number,
and the commit SHA in the `builds` table of our Postgres database.
This saves a few lines of your code around the diff,
with a reference to where the violation happened.
We do this to make our debugging sessions easier.
We do not save in Postgres the whole diff from the pull request.

To browse the portions of the codebase related to
receiving and processing pull request notifications,
try `grep`ing for the following terms:

```bash
grep -R StyleChecker app
grep -R Commenter app
```

Employee access
---------------

All thoughtbot employees have access to change Hound's source code
(the repo you're reading right now, which is open source)
and to push it to GitHub.

All thoughtbot employees have access to
Hound's staging and production Heroku applications and databases.
They can deploy new code, or read and write to the databases.

What you can do to make your Hound use safer
--------------------------------------------

Use environment variables in your code
to [separate code from configuration][12factor]
so we won't accidentally store any credentials or
other sensitive configuration from your app
in our `builds` table.

[12factor]: http://12factor.net/config

Third-party auditing
--------------------

We can't afford to hire a third party security company to audit Hound,
but the codebase is open source.
We believe that transparency and this document can help keep Hound
as secure as possible.
