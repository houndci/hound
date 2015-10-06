# simple-random ![Build status](https://travis-ci.org/ealdent/simple-random.svg?branch=master)

Generate random numbers sampled from the following distributions:

* Beta
* Cauchy
* Chi square
* Dirichlet
* Exponential
* Gamma
* Inverse gamma
* Laplace (double exponential)
* Normal
* Student t
* Triangular
* Uniform
* Weibull

Based on [John D. Cook's SimpleRNG](http://www.codeproject.com/KB/recipes/SimpleRNG.aspx) C# library.

## Installation

### Plain Ruby

Run `gem install simple-random` in your terminal.

### Ruby on Rails

Add `gem 'simple-random', '~> 1.0.0'` to your Gemfile and run `bundle install`.


## Usage

Some of the methods available:

``` ruby
    > @sr = SimpleRandom.new # Initialize a SimpleRandom instance
     => #<SimpleRandom:0x007f9e3ad58010 @m_w=521288629, @m_z=362436069>
    > @sr.set_seed # By default the same random seed is used, so we change it
    > @sr.uniform(0, 5) # Produce a uniform random sample from the open interval (lower, upper).
     => 0.6353204359766096
    > @sr.normal(1000, 200) # Sample normal distribution with given mean and standard deviation
     => 862.5447157384566
    > @sr.exponential(2) # Get exponential random sample with specified mean
     => 0.9386480625062965
    > @sr.triangular(0, 2.5, 10) # Get triangular random sample with specified lower limit, mode, upper limit
     => 3.1083306054169277
```

Note that by default the same seed is used every time to generate the random numbers.  This means that repeated runs should yield the same results.  If you would like it to always initialize with a different seed, or if you are using multiple SimpleRandom objects, you should call `#set_seed` on the instance.

See [lib/simple-random.rb](lib/simple-random/simple_random.rb) for all available methods and options.


## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Distributed under the Code Project Open License, which is similar to MIT or BSD.  See LICENSE for full details (don't just take my word for it that it's similar to those licenses).

## History

### 1.0.1 - 2015-07-31
* Merge purcell's changes to fix numeric seeds

### 1.0.0 - 2014-07-08
* Migrate to new version of Jeweler for gem packaging
* Merge jwroblewski's changes into a new multi-threaded simple random class
* Change from Code Project Open License to [CDDL-1.0](http://opensource.org/licenses/CDDL-1.0)

### 0.10.0 - 2014-03-31
* Sample from triangular distribution (thanks to [benedictleejh](https://github.com/benedictleejh))

### 0.9.3 - 2011-09-16
* Sample from Dirichlet distribution with given set of parameters

### 0.9.2 - 2011-09-06
* Use microseconds for random seed

### 0.9.1 - 2010-07-27
* First stable release
