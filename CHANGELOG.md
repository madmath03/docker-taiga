# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- This CHANGELOG file and CONTRIBUTING.
- Setup HEALTHCHECK on image.

### Changed
- Move base image from python:3.5-jessie to slim-stretch.
- Add themes in taiga options.

### Fixed
- Fix docker-compose with string values as boolean.

## [3.3.13] - 2017-07-23
### Added
- New alpine branch to provide a lighter image.
- Exclude useless files from iage with dockerignore from @jsykes.

### Changed
- Update to taiga 3.3.13 (back and front).
- Lock python to version 3.5 and postgres to version 10.4 from @jsykes.

### Fixed
- Fix external reverse proxy with https @anddann.

## [3.3.8] - 2017-06-14
### Changed
- Update to taiga 3.3.8 (back and front).
- Use default nginx package instead of external one.

## [3.3.6] - 2018-05-29
### Changed
- Update to taiga 3.3.6 (back and front).
- Now, try to migrate on each startup in case of update.
- Restore port to 8000 instead of 8001.

## [3.3.2] - 2018-05-28
### Changed
- Update to taiga 3.3.2 (back and front).
- Use gunicorn to start Django instead of using test server from @anddann.

### Fixed
- Fix some language settings from @anddann.

## 3.3.1 - 2017-09-14
### Changed
- Update to taiga 3.3.1 (back and front).

[Unreleased]: https://github.com/ajira86/docker-taiga/compare/3.3.13...HEAD
[3.3.13]: https://github.com/ajira86/docker-taiga/compare/3.3.8...3.3.13
[3.3.8]: https://github.com/ajira86/docker-taiga/compare/3.3.6...3.3.8
[3.3.6]: https://github.com/ajira86/docker-taiga/compare/3.3.2...3.3.6
[3.3.2]: https://github.com/ajira86/docker-taiga/compare/3.3.1...3.3.2
