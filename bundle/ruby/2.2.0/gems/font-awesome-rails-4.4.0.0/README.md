# font-awesome-rails [![Gem Version](http://img.shields.io/gem/v/font-awesome-rails.svg)](https://rubygems.org/gems/font-awesome-rails) [![Build Status](https://secure.travis-ci.org/bokmann/font-awesome-rails.svg)](http://travis-ci.org/bokmann/font-awesome-rails)

font-awesome-rails provides the
[Font-Awesome](http://fortawesome.github.com/Font-Awesome/) web fonts and
stylesheets as a Rails engine for use with the asset pipeline.

## Installation

Add this to your Gemfile:

```ruby
gem "font-awesome-rails"
```

and run `bundle install`.

## Usage

In your `application.css`, include the css file:

```css
/*
 *= require font-awesome
 */
```
Then restart your webserver if it was previously running.

Congrats! You now have scalable vector icon support. Pick an icon and check out the
[FontAwesome Examples](http://fortawesome.github.io/Font-Awesome/examples/).

### Sass Support

If you prefer [SCSS](http://sass-lang.com/documentation/file.SASS_REFERENCE.html), add this to your
`application.css.scss` file:

```scss
@import "font-awesome";
```

If you use the
[Sass indented syntax](http://sass-lang.com/docs/yardoc/file.INDENTED_SYNTAX.html),
add this to your `application.css.sass` file:

```sass
@import font-awesome
```

### Helpers

There are also some helpers (`fa_icon` and `fa_stacked_icon`) that make your
views _icontastic!_

```ruby
fa_icon "camera-retro"
# => <i class="fa fa-camera-retro"></i>

fa_icon "camera-retro", text: "Take a photo"
# => <i class="fa fa-camera-retro"></i> Take a photo

fa_icon "chevron-right", text: "Get started", right: true
# => Get started <i class="fa fa-chevron-right"></i>

fa_icon "quote-left 4x", class: "text-muted pull-left"
# => <i class="fa fa-quote-left fa-4x text-muted pull-left"></i>

content_tag(:li, fa_icon("check li", text: "Bulleted list item"))
# => <li><i class="fa fa-check fa-li"></i> Bulleted list item</li>
```

```ruby
fa_stacked_icon "twitter", base: "square-o"
# => <span class="fa-stack">
# =>   <i class="fa fa-square-o fa-stack-2x"></i>
# =>   <i class="fa fa-twitter fa-stack-1x"></i>
# => </span>

fa_stacked_icon "dollar inverse", base: "circle", class: "fa-5x"
# => <span class="fa-stack fa-5x">
# =>   <i class="fa fa-circle fa-stack-2x"></i>
# =>   <i class="fa fa-dollar fa-inverse fa-stack-1x"></i>
# => </span>

fa_stacked_icon "terminal inverse", base: "square", class: "pull-right", text: "Hi!"
# => <span class="fa-stack pull-right">
# =>   <i class="fa fa-square fa-stack-2x"></i>
# =>   <i class="fa fa-terminal fa-inverse fa-stack-1x"></i>
# => </span> Hi!

```

## Misc

**Note:** In Rails 3.2, make sure font-awesome-rails is outside the bundler asset group
so that these helpers are automatically loaded in production environments.

**Note when deploying to sub-folders**
It is sometimes the case that deploying a Rails application to a production
environment requires the application to be hosted at a sub-folder on the server.
This may be the case, for example, if Apache HTTPD or Nginx is being used as a
front-end proxy server, with Rails handling only requests that come in to a sub-folder
such as `http://example.com/myrailsapp`. In this case, the
FontAwesome gem (and other asset-serving engines) needs to know the sub-folder,
otherwise you can experience a problem roughly described as ["my app works
fine in development, but fails when I deploy
it"](https://github.com/bokmann/font-awesome-rails/issues/74).

To fix this, set the *relative URL root* for the application. In the
environment file for the deployed version of the app, for example
`config/environments/production.rb`,
set the config option `action_controller.relative_url_root`:

    MyApp::Application.configure do
      ...

      # set the relative root, because we're deploying to /myrailsapp
      config.action_controller.relative_url_root  = "/myrailsapp"

      ...
    end

The default value of this variable is taken from `ENV['RAILS_RELATIVE_URL_ROOT']`,
so configuring the environment to define `RAILS_RELATIVE_URL_ROOT` is an alternative strategy.

## Versioning

Versioning follows the core releases of Font-Awesome which follows Semantic
Versioning 2.0 as defined at <http://semver.org>. We will do our best not to
make any breaking changes until Font-Awesome core makes a major version bump.

## License

* The [Font Awesome](http://fortawesome.github.com/Font-Awesome) font is
  licensed under the [SIL Open Font License](http://scripts.sil.org/OFL).
* [Font Awesome](http://fortawesome.github.com/Font-Awesome) CSS files are
  licensed under the
  [MIT License](http://opensource.org/licenses/mit-license.html).
* The remainder of the font-awesome-rails project is licensed under the
  [MIT License](http://opensource.org/licenses/mit-license.html).
