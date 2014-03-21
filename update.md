# Hound Update

## What

First off, Hound is a development tool that helps project teams maintain consistent code style. It does this by reviewing pull requests and commenting on GitHub if style differs from the team's style guide. A side effect of using Hound is it helps developers focus when reviewing pull requests, and not worry about code style.

## How

Hound uses RuboCop, Octokit, and Rails to do its thing. After you authenticate with Hound, using GitHub, you can enable Hound for any of your repos. When you do that a web hook is created on GitHub so Hound will be notified when there is pull request activity. After Hound is notified of pull request activity it will fetch the files that were modified and run them through RuboCop. If there is a violation in any changed code, Hound will comment on the line with a description of the difference.

## Who

A [few of us](https://github.com/thoughtbot/hound/graphs/contributors) have been working on Hound for a while. It's stable and is actively used in and out of thoughtbot, so please check it out, contribute, and turn it on for your current projects.

## Traction

* Users: 165
* Projects monitored by Hound: 314
* Number of times Hound has checked code: 2433
* Number of times Hound has found issues: 1132

## What's Next?

We plan on doing some additional design work next, now that the service is functional and stable. The landing page will be updated and we will work on making it easier for users to get started. We also plan on formally releasing Hound free for open source projects and a paid plan for private.
