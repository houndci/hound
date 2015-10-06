# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased][unreleased]
- Nothing.

## [0.6.1] - 2015-08-06
### Fixed
- Support Rails versions back to 4.0.4. Thanks, @walidvb.

## [0.6.0] - 2015-07-07
### Added
- Apply user-supplied [custom
transformations](https://github.com/jamesmartin/inline_svg/blob/master/README.md#custom-transformations) to a document.

## [0.5.3] - 2015-06-22
### Added
- `preserveAspectRatio` transformation on SVG root node. Thanks, @paulozoom.

## [0.5.2] - 2015-04-03
### Fixed
- Support Sprockets v2 and v3 (Sprockets::Asset no longer to_s to a filename)

## [0.5.1] - 2015-03-30
### Warning
*** This version is NOT comaptible with Sprockets >= 3.***

### Fixed
- Support for ActiveSupport (and hence, Rails) 4.2.x. Thanks, @jmarceli.

## [0.5.0] - 2015-03-29
### Added
- A new option: `id` adds an id attribute to the SVG.
- A new option: `data` adds data attributes to the SVG.

### Changed
- New options: `height` and `width` override `size` and can be set independently.

## [0.4.0] - 2015-03-22
### Added
- A new option: `size` adds width and height attributes to an SVG. Thanks, @2metres.

### Changed
- Dramatically simplified the TransformPipeline and Transformations code.
- Added tests for the pipeline and new size transformations.

### Fixed
- Transformations can no longer be created with a nil value.

## [0.3.0] - 2015-03-20
### Added
- Use Sprockets to find canonical asset paths (fingerprinted, post asset-pipeline).

## [0.2.0] - 2014-12-31
### Added
- Optionally remove comments from SVG files. Thanks, @jmarceli.

## [0.1.0] - 2014-12-15
### Added
- Optionally add a title and description to a document. Thanks, ludwig.schubert@qlearning.de.
- Add integration tests for main view helper. Thanks, ludwig.schubert@qlearning.de.

## 0.0.1 - 2014-11-24
### Added
- Basic Railtie and view helper to inline SVG documents to Rails views.

[unreleased]: https://github.com/jamesmartin/inline_svg/compare/v0.6.1...HEAD
[0.6.1]: https://github.com/jamesmartin/inline_svg/compare/v0.6.0...v0.6.1
[0.6.0]: https://github.com/jamesmartin/inline_svg/compare/v0.5.3...v0.6.0
[0.5.3]: https://github.com/jamesmartin/inline_svg/compare/v0.5.2...v0.5.3
[0.5.2]: https://github.com/jamesmartin/inline_svg/compare/v0.5.1...v0.5.2
[0.5.1]: https://github.com/jamesmartin/inline_svg/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/jamesmartin/inline_svg/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/jamesmartin/inline_svg/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/jamesmartin/inline_svg/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/jamesmartin/inline_svg/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/jamesmartin/inline_svg/compare/v0.0.1...v0.1.0
