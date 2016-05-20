### 3.3.0 / 2015-06-12
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.2.2...v3.3.0)

Enhancements:

* Improve formatting of arrays and hashes in failure messages so they
  use our custom formatting of matchers, time objects, etc.
  (Myron Marston, Nicholas Chmielewski, #205)
* Use improved formatting for diffs as well. (Nicholas Chmielewski, #205)

Bug Fixes:

* Fix `FuzzyMatcher` so that it checks `expected == actual` rather than
  `actual == expected`, which avoids errors in situations where the
  `actual` object's `==` is improperly implemented to assume that only
  objects of the same type will be given. This allows rspec-mocks'
  `anything` to match against objects with buggy `==` definitions.
  (Myron Marston, #193)

### 3.2.2 / 2015-02-23
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.2.1...v3.2.2)

Bug Fixes:

* Fix an encoding issue with `EncodedString#split` when encountering an
  invalid byte string. (Benjamin Fleischer, #1760)

### 3.2.1 / 2015-02-04
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.2.0...v3.2.1)

Bug Fixes:

* Fix `RSpec::CallerFilter` to work on Rubinius 2.2.
  (Myron Marston, #169)

### 3.2.0 / 2015-02-03
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.1.2...v3.2.0)

Enhancements:

* Add extra Ruby type detection. (Jon Rowe, #133)
* Make differ instance re-usable. (Alexey Fedorov, #160)

Bug Fixes:

* Do not consider `[]` and `{}` to match when performing fuzzy matching.
  (Myron Marston, #157)

### 3.1.2 / 2014-10-08
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.1.1...v3.1.2)

Bug Fixes:

* Fix method signature to not blow up with a `NoMethodError` on 1.8.7 when
  verifying against an RSpec matcher. (Myron Marston, #116)

### 3.1.1 / 2014-09-26
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.1.0...v3.1.1)

Bug Fixes:

* Fix `RSpec::Support::DirectoryMaker` (used by `rspec --init` and
  `rails generate rspec:install`) so that it detects absolute paths
   on Windows properly. (Scott Archer, #107, #108, #109) (Jon Rowe, #110)

### 3.1.0 / 2014-09-04
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.0.4...v3.1.0)

Bug Fixes:

* Fix `FuzzyMatcher` so that it does not wrongly match a struct against
  an array. (Myron Marston, #97)
* Prevent infinitely recursing `#flatten` methods from causing the differ
  to hang. (Jon Rowe, #101)

### 3.0.4 / 2014-08-14
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.0.3...v3.0.4)

Bug Fixes:

* Fix `FuzzyMatcher` so that it does not silence `ArgumentError` raised
  from broken implementations of `==`. (Myron Marston, #94)

### 3.0.3 / 2014-07-21
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.0.2...v3.0.3)

Bug Fixes:

* Fix regression in `Support#method_handle_for` where proxy objects
  with method delegated would wrongly not return a method handle.
  (Jon Rowe, #90)
* Properly detect Module#prepend support in Ruby 2.1+ (Ben Langfeld, #91)
* Fix `rspec/support/warnings.rb` so it can be loaded and used in
  isolation. (Myron Marston, #93)

### 3.0.2 / 2014-06-20
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.0.1...v3.0.2)

* Revert `BlockSignature` change from 3.0.1 because of a ruby bug that
  caused it to change the block's behavior (https://bugs.ruby-lang.org/issues/9967).
  (Myron Marston, rspec-mocks#721)

### 3.0.1 / 2014-06-19
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.0.0...v3.0.1)

* Fix `BlockSignature` so that it correctly differentiates between
  required and optional block args. (Myron Marston, rspec-mocks#714)

### 3.0.0 / 2014-06-01
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.0.0.rc1...v3.0.0)

### 3.0.0.rc1 / 2014-05-18
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.0.0.beta2...v3.0.0.rc1)

### 3.0.0.beta2 / 2014-02-17
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.0.0.beta1...v3.0.0.beta2)

Bug Fixes:

* Issue message when :replacement is passed to `RSpec.warn_with`. (Jon Rowe)

### 3.0.0.beta1 / 2013-11-07
[Full Changelog](https://github.com/rspec/rspec-support/compare/0dc12d1bdbbacc757a9989f8c09cd08ef3a4837e...v3.0.0.beta1)

Initial release.
