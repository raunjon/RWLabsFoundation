# RWLabsFoundation

Formatting and convenience helpers for RWLabs apps: Region (country, currency, locale, time zone) presets for every country, date and currency formatting, relative time, and small Swift and SwiftUI conveniences. It has no dependencies.

## Requirements

- iOS 15+ / macOS 12+
- Xcode 16+ (swift-tools-version 6.0; the package builds in Swift 5 language mode)

## Installation

Releases are tagged with semantic versions. Add the package by version:

```swift
dependencies: [
    .package(url: "https://github.com/raunjon/RWLabsFoundation.git", from: "1.0.0")
],
targets: [
    .target(
        name: "MyApp",
        dependencies: [
            .product(name: "RWLabsFoundation", package: "RWLabsFoundation")
        ]
    )
]
```

In Xcode: File → Add Package Dependencies…, enter the repository URL and choose **Up to Next Major Version** from `1.0.0`.

## Region

`Region` holds a country code, currency code, locale and time zone. There is a preset for every country, generated from system data:

```swift
Region.india            // IN, INR, en_IN, Asia/Kolkata
Region.unitedStates     // US, USD, en_US, America/New_York
Region.unitedKingdom    // GB, GBP, en_GB, Europe/London
Region(countryCode: "jp")   // lookup by ISO code, case-insensitive
Region.all              // every preset, sorted by code (Identifiable, ready for a picker)
Region.device           // the device's own settings
```

Every preset uses an `en_<country>` locale: English text with the country's number and date formats. Countries spanning several time zones use the capital's or the most populous one.

Each region also gives you `countryName()`, `currencyName()`, `currencySymbol` and a Gregorian `calendar` in its time zone.

`Region.current` is what the formatting helpers default to. It starts as INR with the device's locale and time zone; set it once at launch.

## Formatting helpers

```swift
1234.5.toCurrency()                            // "₹1,234.50" with Region.current = .india
Decimal(string: "19.99")!.toCurrency(code: "USD", locale: Locale(identifier: "en_US"))
date.toString(fromFormat: DateFormats.pretty)  // display: Region.current's locale and time zone
"2026-01-02T03:04:05".toDate()                 // parsing: always en_US_POSIX
"2026-01-02T03:04:05.123+05:30".toISO8601Date()
date.toString(.feedDate)                       // named formats: "10 May 2026 • 11:45 pm"
date.toString(.iso8601)                        // ISO/backend formats default to en_US_POSIX
"2026-05-10".toDate(.yyyyMMdd)
date.toString(.relativeDay)                    // "Yesterday", or the locale's medium date
date.add(days: 1)                              // same wall-clock time across DST changes
Utils.getLastPosted(dateString: createdAt)     // "2 hours ago", or "02 Jan, 2026" after a week
Utils.getTimestamp(dateString: createdAt)      // "5m", "3h", "2d"
```

Parsing fixed-format strings always uses `Locale.posix`, so it works whatever the device's language or 12/24-hour setting. Display formatting uses `Region.current` unless you pass a locale or time zone.

Also included: `Array.chunked(into:)` and `move`, JSON conveniences on `Data`, `Encodable` and `Dictionary`, `String.emptyToNil()` / `String?.nilToEmpty()`, `Int.toDate()` (Unix seconds), and `DateFormats` / `Unicodes` constants. Use `DateFormat("…")` for a pattern that has no named format.

## Development

```bash
swift build
```

```bash
swift test
```

To run the tests on iOS, pick a simulator from `xcodebuild -scheme RWLabsFoundation -showdestinations`:

```bash
xcodebuild test -scheme RWLabsFoundation -destination 'platform=iOS Simulator,id=<simulator-id>'
```

The country presets in `Sources/RWLabsFoundation/Region/Region+Countries.swift` are generated. To change them, edit `Scripts/GenerateRegions.swift` and run, on macOS:

```bash
swift Scripts/GenerateRegions.swift > Sources/RWLabsFoundation/Region/Region+Countries.swift
```
