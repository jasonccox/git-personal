# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- `mkrepo --from` now allows creating a repo that is a copy of a remote repo.

## [0.2.0] - 2021-05-27
### Changed
- **Breaking** Change default Git repo directory to `/home/git`. To continue using the previous directory, simply set `GIT_REPO_DIR=/home/git/repos` in the container's environment.

## [0.1.0] - 2021-05-08
### Added
- Create initial version running Git v2.30.2-r0 and OpenSSH v8.4\_p1-r3 on an Alpine Linux v3.13 base.
