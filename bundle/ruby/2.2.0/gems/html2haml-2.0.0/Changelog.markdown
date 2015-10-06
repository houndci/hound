# HTML2Haml Changelog

## 2.0.0

* Switch to Nokogiri for XML parsing.
  (thanks to [Stefan Natchev](https://github.com/snatchev) and [Norman
  Clarke](https://github.com/norman))

* Add Ruby 2.0 support.
  (thanks to [Yasuharu Ozaki](https://github.com/yasuoza))

* Add option to use Ruby 1.9-style attributes when possible.
  (thanks to [Yoshinori Kawasaki](https://github.com/luvtechno) and
  [Alexander Egorov](https://github.com/qatsi))

* Updated dependency versions.

* Removed some deprecated configuration flags.

* Move the internal HTML class from the Haml namespace into the Html2haml
  namespace.

## 1.0.1

Rescue from `RubyParser::SyntaxError` in check for valid ruby.

## 1.0.0

* Extracted from Haml and released as an independent gem. For changes from
  previous versions, see the Haml changelog.
