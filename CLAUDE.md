# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

RWLabsFoundation is a dependency-free Swift package of formatting and convenience helpers for RWLabs/ThirtyPlus apps. It was split out of RWLabsDataServiceKit, which now depends on it (that package must stay a consumer: never add a dependency on the networking library here). Apps consume tagged releases from GitHub (`raunjon/RWLabsFoundation`), so public API changes need a version bump: major for breaking changes. README.md is the user-facing guide; keep its examples in sync with API changes.

## Build & test

```bash
swift build
```

```bash
swift test
```

Run a single test with `swift test --filter <Suite>/<testName>`. To check iOS as well, use the `RWLabsFoundation` scheme with a simulator id from `xcodebuild -scheme RWLabsFoundation -showdestinations` (names are ambiguous across installed runtimes):

```bash
xcodebuild test -scheme RWLabsFoundation -destination 'platform=iOS Simulator,id=<simulator-id>'
```

Tests use Swift Testing. Locale-formatted output (currency, relative dates) differs between ICU versions on iOS and macOS, so compare it loosely (e.g. ignore whitespace).

Package: swift-tools 6.0 in Swift 5 language mode (`swiftLanguageModes: [.v5]`), iOS 15+ / macOS 12+. Releases are semver git tags (`1.0.0` first), consumed with `from:`/Up to Next Major. Run the tests on macOS and iOS before tagging, and never commit `.build/` or `xcuserdata/` (see `.gitignore`).

## Architecture

Date parsing/formatting (`String.toDate`, `toISO8601Date`, `Date.toString`, named `DateFormat`s whose ISO/backend formats default to `Locale.posix`, DST-safe `add(days:)`), locale-aware currency (`toCurrency(code:locale:)`, also on `Decimal`), relative time (`Utils.getLastPosted`/`getTimestamp`), JSON conveniences (including `Data.prettyPrintedJSON`, used by RWLabsDataServiceKit's logging), `URL.queryParameters`, small SwiftUI helpers (`Binding`, `View` conditionals), and `Unicodes`/`DateFormats` constants.

Sources are grouped by area under `Sources/RWLabsFoundation/`: `Region/`, `Dates/`, `Formatting/` (currency, relative time), `Extensions/` (general Swift/Foundation conveniences), and `SwiftUI/` (the only files that import SwiftUI; keep them there so they can become a separate target if needed). `Constants.swift` stays at the root.

Conventions: fixed-format parsing uses `Locale.posix` and is unaffected by region; display formatting (currency code, locale, time zone, calendar) defaults to `Region.current` (country, currency, locale, time zone; starts as `Region.default` = INR with the device's locale/time zone, presets `.india` and `.device`, set once at app launch). Tests that change `Region.current` must restore it and keep its time zone, since suites run in parallel; formatters are cached in `DateFormatterCache`; time-dependent helpers take `now:`/`calendar:` parameters for tests. RWLabsDataServiceKit uses these extension members directly, so it must not declare the same members, or call sites importing both modules become ambiguous.

`Region+Countries.swift` (one `Region` preset per ISO country plus `Region.all`, looked up with `Region(countryCode:)`) is generated; do not edit it by hand. Change `Scripts/GenerateRegions.swift` (primary time zones for multi-zone countries, property-name overrides) and regenerate on macOS:

```bash
swift Scripts/GenerateRegions.swift > Sources/RWLabsFoundation/Region/Region+Countries.swift
```
