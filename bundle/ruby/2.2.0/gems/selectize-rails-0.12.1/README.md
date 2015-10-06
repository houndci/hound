# selectize-rails [![Gem Version](https://badge.fury.io/rb/selectize-rails.png)](http://badge.fury.io/rb/selectize-rails)

selectize-rails provides the [selectize.js](http://brianreavis.github.io/selectize.js/)
plugin as a Rails engine to use it within the asset pipeline.

## Installation

Add this to your Gemfile:

```ruby
gem "selectize-rails"
```

and run `bundle install`.

## Usage

In your `application.js`, include the following:

```js
//= require selectize
```

In your `application.css`, include the following:

```css
 *= require selectize
 *= require selectize.default
```

### Themes

To include additional theme's you can replace the `selectize.default` for one of the [theme files](https://github.com/brianreavis/selectize.js/tree/master/dist/css)


## Examples

See the [demo page of Brian Reavis](http://brianreavis.github.io/selectize.js/) for examples how to use the plugin

## Changes

| Version  | Notes                                                       |
| --------:| ----------------------------------------------------------- |
|   0.12.0 | Update to v0.12.0 of selectize.js                           |
|   0.11.2 | Update to v0.11.2 of selectize.js                           |
|   0.11.0 | Update to v0.11.0 of selectize.js                           |
|   0.9.1  | Update to v0.9.1 of selectize.js                            |
|   0.9.0  | Update to v0.9.0 of selectize.js                            |
|   0.8.5  | Update to v0.8.5 of selectize.js                            |
|   0.8.4  | Update to v0.8.4 of selectize.js                            |
|   0.8.3  | Update to v0.8.3 of selectize.js                            |

[older](CHANGELOG.md)

## License

* The [selectize.js](http://brianreavis.github.io/selectize.js/) plugin is licensed under the
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)
* The [selectize-rails](https://github.com/manuelvanrijn/selectize-rails) project is
 licensed under the [MIT License](http://opensource.org/licenses/mit-license.html)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
