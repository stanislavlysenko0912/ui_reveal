# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.0.1] - 2026-03-09

### Fixed

- Removed runtime usage of `RenderRepaintBoundary.debugNeedsPaint` during snapshot capture.
- Prevented `LateInitializationError` in release mode on real devices when starting reveal transitions.

## [1.0.0] - 2026-02-17

### Added

- Initial public release of `ui_reveal`.
- `RevealScope` and `RevealController` APIs for snapshot-based transitions.
- Built-in effects: circular, fade, slide, diagonal wipe, and liquid wave.
- `BuildContext` extension helpers for reveal trigger and center detection.
- Example app pages for simple usage, real-world usage, playground, and custom effects.
