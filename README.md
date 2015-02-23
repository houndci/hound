Mnd-Hound
=========

Hound is a bot reviewing pull requests in activated projects for styleguide violations.

Activate your mynewsdesk repo today at:

https://mnd-hound.herokuapp.com

### Styleguides

Styleguides are based on Hound defaults with overrides under `config/style_guides/mynewsdesk`

### App specific styleguides

Overriding styleguide can be done in individual projects by adding a .hound.yml file.
However this is highly discouraged as we want to keep style consistency for the all
mynewsdesk projects. More info on configuration at:

https://houndci.com/configuration

### Y U NO?

If you find it hard to sleep at night due to horrible style ideas being forced upon
you by the terror of the hound: Try creating a Pull Request and get the majority
of the team to agree with you in the comments.

Now back to the original README...

Hound
=====

[![Build Status](https://travis-ci.org/thoughtbot/hound.svg?branch=master)](http://travis-ci.org/thoughtbot/hound?branch=master)
[![Code Climate](https://codeclimate.com/repos/526ab75ff3ea007df603b773/badges/32cb8e64b2e265d8cad6/gpa.svg)](https://codeclimate.com/repos/526ab75ff3ea007df603b773/feed)

This codebase is the Rails app for
[Hound](http://houndci.com),
a hosted service
that reviews GitHub pull requests
for Ruby, JavaScript, CoffeeScript, and SCSS
style guide violations.

If you have questions about the service,
see our [FAQ] or email [hound@thoughtbot.com].

To contribute to the Hound codebase,
see the [CONTRIBUTING.md] file.

[FAQ]: https://houndci.com/faq
[hound@thoughtbot.com]: mailto:hound@thoughtbot.com
[CONTRIBUTING.md]: CONTRIBUTING.md

## License

The names and logos for Hound are trademarks of thoughtbot, inc.

Hound is Copyright © 2015 thoughtbot, inc.  It is free software, and may be
redistributed under the terms specified in the [LICENSE](LICENSE) file.
