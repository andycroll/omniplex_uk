# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [1.0.2] - 2026-11-03

### Fixed
- Placeholder `Live event test` sessions are left out of performances.

## [1.0.1] - 2026-11-02

### Changed
- Requests and London times use cinebase 5.8's `Cinebase::Http` and `Cinebase::London`.

## [1.0.0] - 2026-11-01

### Added
- `OmniplexUk::Cinema.all` and `OmniplexUk::Cinema.new(id)` for Omniplex's UK cinemas in Great Britain and Northern Ireland, from the site picker on the omniplexcinemas.co.uk home page, with addresses and coordinates from each venue's listings page, or OpenStreetMap where it has none.
- `OmniplexUk::Performance.at(id, from:, to:)`, reading the venue's advertised dates and then one listings page per date in the range over one kept-alive connection, with booking links, variants for Omniplex's hall icons and showtime tags, languages and film years from titles.
- Fixtures trimmed from live pages, a live shape test that checks real responses without storing them, and GitHub Actions CI and release workflows.
