# datetime_picker_rails

Forked from [TrevorS/bootstrap-datetimepicker-rails][original] on Sept 3, 2015.

My goal is to make it not require [bootstrap-sass].

[original]: https://github.com/TrevorS/bootstrap3-datetimepicker-rails
[bootstrap-sass]: https://github.com/twbs/bootstrap-sass

- - -

This gem packages the [bootstrap-datetimepicker]
for the Rails 3.1+ asset pipeline.

[bootstrap-datetimepicker]: https://github.com/Eonasdan/bootstrap-datetimepicker

## Installation

Add these lines to your application's Gemfile:

```ruby
gem "datetime_picker_rails", github: "graysonwright/datetime_picker_rails"
```

And then execute:

```bash
$ bundle
```

If your server is running,
you will need to **restart Rails** before using the gem.

Add the following to your JavaScript manifest file (`application.js`):
```js
//= require moment
//= require datetime_picker
```

If you want to include a localization, also add:
```js
//= require moment/<locale>
```

Add the following to your style sheet file:

If you are using SCSS, modify your `application.css.scss`
```scss
@import "datetime_picker";
```

If you're using plain CSS, modify your `application.css`
```css
*= require datetime_picker
```

## Usage

Check out the documentation at:
http://eonasdan.github.io/bootstrap-datetimepicker/

## Problems

Clone https://github.com/TrevorS/bs3dp-test and try to reproduce your issue.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
