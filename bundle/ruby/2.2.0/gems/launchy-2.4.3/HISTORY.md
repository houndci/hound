# Launchy Changelog

## Version 2.4.3 - 2014-11-03
* Update documentation - <https://github.com/copiousfreetime/launchy/pull/81> - supremebeing7
* Fix launching of `exo-open` for XFCE - <https://github.com/copiousfreetime/launchy/issues/82> - dsandstrom
* Add iceweasel as a fallback browser - <https://github.com/copiousfreetime/launchy/pull/92> -  jackturnbull
* Reopen $stderr in really bad situation - <https://github.com/copiousfreetime/launchy/pull/77> - infertux

## Version 2.4.2 - 2013-11-28
* Fix kde issue - <https://github.com/copiousfreetime/launchy/issues/72> - colbell

## Version 2.4.1 - 2013-11-26
* Abstract out the argv of the commandline - <https://github.com/copiousfreetime/launchy/issues/71>

## Version 2.4.0 - 2013-11-12
* Support `Launchy.open( url, :debug => true )` - <http://github.com/copiousfreetime/launchy/issues/63> - schmich
* Fix inconsistencies in `debug?` and `dry_run?` methods - <http://github.com/copiousfreetime/launchy/issues/63> - schmich
* Fix detection of missing *nix desktops - <http://github.com/copiousfreetime/launchy/issues/70>
* Fix running tests in bare Linux environment - <http://github.com/copiousfreetime/launchy/issues/67> - gioele
* Fix mistaking windows drive as uri schema - <http://github.com/copiousfreetime/launchy/issues/65>
* Attempt fixing windows `start` command oddities, again - <http://github.com/copiousfreetime/launchy/issues/62>

## Version 2.3.0 - 2013-04-11

* Add the option to call a block on error instead of raising an exception

## Version 2.2.0 - 2013-02-06

* Change XFCE detection to not depend on grep <http://github.com/copiousfreetime/launchy/issues/52> - bogdan
* Suppress forked process output <http://github.com/copiousfreetime/launchy/issues/51>
* Display help/usage if no url is given <http://github.com/copiousfreetime/launchy/issues/54>
* Detect the fluxbox environment <http://github.com/copiousfreetime/launchy/issues/53>
* Automatically detect `http` url's if they are missing the `http://` <http://github.com/copiousfreetime/launchy/issues/55>
* Update to latest project management rake tasks

## Version 2.1.2 - 2012-08-06

* Fix where HostOS would fail to convert to string on JRuby in 1.9 mode <http://github.com/copiousfreetime/launchy/issues/45>

## Version 2.1.1 - 2012-07-28

* Update addressable runtime dependency <http://github.com/copiousfreetime/launchy/issues/47>
* Bring minitest and ffi development dependencies up to date

## Version 2.1.0 - 2012-03-18

* Fix raising exception when no browser program found <http://github.com/copiousfreetime/launchy/issues/42>
* Add `LAUNCHY_DRY_RUN` environment variable (Mariusz Pietrzyk / wijet)
* Update dependencies

## Version 2.0.5 - 2011-07-24

* Fix the case where `$BROWSER` is set and no *nix desktop was found <http://github.com/copiousfreetime/launchy/issues/33>

## Version 2.0.4 - 2011-07-23

* Fix windows `start` commandline <http://github.com/copiousfreetime/launchy/issues/5>
* Add capability to open local files with no file: scheme present <http://github.com/copiousfreetime/launchy/issues/29>
* Added `rake how_to_contribute` task <http://github.com/copiousfreetime/launchy/issues/30>
* Make better decisions on when to do shell escaping <http://github.com/copiousfreetime/launchy/issues/31>
* Switch to Addressable::URI so UTF-8 urls may be parsed. <http://github.com/copiousfreetime/launchy/issues/32>

## Version 2.0.3 - 2011-07-17

* Add in Deprecated API wrappers that warn the user

## Version 2.0.2 - 2011-07-17

* Typo fixes from @mtorrent
* Documentation updates explicitly stating the Public API
* Increase test coverage

## Version 2.0.1 - 2011-07-16

* Almost a complete rewrite
* JRuby Support
* Organization is such that it will be easier to add additional applications
* Windows behavior possibly fixed, again

## Version 1.0.0 - 2011-03-17

* Add JRuby support (Stephen Judkins)
* Remove unused Paths module
* Switch to using bones
* Switch to use minitest
* NOTE, this version was never released.

## Version 0.4.0 - 2011-01-27

* Add support for `file:///` schema (postmodern)

## Version 0.3.7 - 2010-07-19

* Fix launchy on windows (mikefarmer)

## Version 0.3.6 - 2010-02-22

* add a test:spec task to run tests without rcov support
* added `testing` os family for running tests

## Version 0.3.5 - 2009-12-17

* clarify that launchy is under ISC license
* fix missing data file in released gem needed for running specs

## Version 0.3.3 - 2009-02-19

* pass command line as discrete items to system() to avoid string
  interpretation by the system shell. (Suraj N. Kurapati)
* rework project layout and tasks

## Version 0.3.2 - 2008-05-21

* detect aix and mingw as known operating systems.

## Version 0.3.1 - 2007-09-08

* finalize the command line wrapper around the launchy library.
* added more tests

## Version 0.3.0 - 2007-08-30

* reorganize the code structure, removing Spawnable namespace
* removed `do_magic` method, changed it to `open`
* added override environment variable LAUNCHY_HOST_OS for testing
* fix broken cygwin support [Bug #13472]

## Version 0.2.1 - 2007-08-18

* fix inability to find windows executables [Bug #13132]

## Version 0.2.0 - 2007-08-11

* rework browser finding
* manual override with `LAUNCHY_BROWSER` environment variable
* on *nix use desktop application launcher with fallback to list of browsers
* On windows, switch to 'start' command and remove dependency on win32-process
* removed win32 gem
* Add debug output by setting `LAUNCHY_DEBUG` environment variable to `true`

## Version 0.1.2 - 2007-08-11

* forked child exits without calling `at_exit` handlers

## Version 0.1.1

* fixed rubyforge task to release mswin32 gem also

## Version 0.1.0

* Initial public release
* switched to using fork to spawn process and `require 'win32/process'` if on windows

## Version 0.0.2

* First attempt at using systemu to spawn processes

## Version 0.0.1

* Initially working release
