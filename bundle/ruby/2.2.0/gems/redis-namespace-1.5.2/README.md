redis-namespace
---------------

Requires the redis gem.

Namespaces all Redis calls.

``` ruby
r = Redis::Namespace.new(:ns, :redis => @r)
r['foo'] = 1000
```

This will perform the equivalent of:

    redis-cli set ns:foo 1000

Useful when you have multiple systems using Redis differently in your app.


Installation
============

    $ gem install redis-namespace



Testing
=======

    $ bundle install
    $ rake


Author
=====

Chris Wanstrath :: chris@ozmm.org
Terence Lee :: hone02@gmail.com
