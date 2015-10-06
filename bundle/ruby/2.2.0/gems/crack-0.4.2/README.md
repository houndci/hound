# crack

Really simple JSON and XML parsing, ripped from Merb and Rails. The XML parser is ripped from Merb and the JSON parser is ripped from Rails. I take no credit, just packaged them for all to enjoy and easily use.

## compatibility

* ruby 1.8.7
* ruby 1.9+ (3 failures related to time parsing, would love it if someone could figure them out)

## note on patches/pull requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* `script/test` - this will bootstrap and run the tests
* Commit, do not mess with rakefile, version, or history. (if you want to have your own version, that is fine but bump version in a commit by itself in another branch so I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## usage
  
```ruby
gem 'crack' # in Gemfile
require 'crack' # for xml and json
require 'crack/json' # for just json
require 'crack/xml' # for just xml
```

## examples
  
```ruby
Crack::XML.parse("<tag>This is the contents</tag>")
# => {'tag' => 'This is the contents'}

Crack::JSON.parse('{"tag":"This is the contents"}')
# => {'tag' => 'This is the contents'}
```

## Copyright

Copyright (c) 2009 John Nunemaker. See LICENSE for details.

## Docs

http://rdoc.info/projects/jnunemaker/crack
