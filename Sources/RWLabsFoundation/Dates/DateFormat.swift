//
//  DateFormat.swift
//  RWLabsFoundation
//
//  Created by RWLabs
//

import Foundation

/// Named date formats for `Date.toString(_:)` and `String.toDate(_:)`
///
/// Examples show 2026-05-10 23:45:12 in `en_GB`. Use `DateFormat("…")` for a
/// pattern not listed here. Machine-readable formats (ISO and backend) always
/// format with `Locale.posix` unless you pass a locale.
public struct DateFormat: Hashable, Sendable {
    enum Kind: Hashable, Sendable {
        case pattern(String)
        case relativeDay
        case unixTimestamp
    }

    let kind: Kind
    /// Whether formatting defaults to `Locale.posix` rather than `Region.current.locale`
    public let isMachineReadable: Bool

    public init(_ pattern: String, isMachineReadable: Bool = false) {
        self.init(kind: .pattern(pattern), isMachineReadable: isMachineReadable)
    }

    init(kind: Kind, isMachineReadable: Bool) {
        self.kind = kind
        self.isMachineReadable = isMachineReadable
    }

    /// The `DateFormatter` pattern; `nil` for `relativeDay` and `unixTimestamp`
    public var pattern: String? {
        if case .pattern(let pattern) = kind { return pattern }
        return nil
    }

    // MARK: - ISO Formats

    /// 2026-05-10T11:53:24Z (or an offset such as +05:30)
    public static let iso8601 = DateFormat("yyyy-MM-dd'T'HH:mm:ssXXXXX", isMachineReadable: true)

    /// 2026-05-10T11:53:24.883Z
    public static let iso8601Milliseconds = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX", isMachineReadable: true)

    // MARK: - Standard Date Formats

    /// 2026-05-10
    public static let yyyyMMdd = DateFormat("yyyy-MM-dd", isMachineReadable: true)

    /// 10/05/2026
    public static let ddMMyyyy = DateFormat("dd/MM/yyyy")

    /// 05/10/2026
    public static let mmddyyyy = DateFormat("MM/dd/yyyy")

    /// 10 May 2026
    public static let ddMMMYYYY = DateFormat("dd MMM yyyy")

    /// 10 May, 2026
    public static let ddMMMCommaYYYY = DateFormat("dd MMM, yyyy")

    /// 10 May 2026, Sunday
    public static let ddMMMMYYYYEEEE = DateFormat("dd MMMM yyyy, EEEE")

    /// 10 May 2026
    public static let ddMMMMYYYY = DateFormat("dd MMMM yyyy")

    // MARK: - Time Formats

    /// 23:45
    public static let time24Hour = DateFormat("HH:mm")

    /// 11:45 pm
    public static let time12Hour = DateFormat("hh:mm a")

    /// 23:45:12
    public static let fullTime24Hour = DateFormat("HH:mm:ss")

    /// 11:45:12 pm
    public static let fullTime12Hour = DateFormat("hh:mm:ss a")

    // MARK: - Date & Time

    /// 2026-05-10 23:45:12
    public static let fullDateTime24 = DateFormat("yyyy-MM-dd HH:mm:ss", isMachineReadable: true)

    /// 10 May 2026 11:45 pm
    public static let fullDateTime12 = DateFormat("dd MMM yyyy hh:mm a")

    /// 10 May 2026 • 11:45 pm
    public static let feedDate = DateFormat("dd MMM yyyy • hh:mm a")

    /// Sunday, 10 May 2026 • 11:45 pm
    public static let detailedFeedDate = DateFormat("EEEE, dd MMM yyyy • hh:mm a")

    // MARK: - Chat / Messaging

    /// 11:45 pm
    public static let chatTimestamp = DateFormat("hh:mm a")

    /// Today, Yesterday, Tomorrow, otherwise the locale's medium date (10 May 2026); format-only
    public static let relativeDay = DateFormat(kind: .relativeDay, isMachineReadable: false)

    /// 10 May, 11:45 pm
    public static let messageDate = DateFormat("dd MMM, hh:mm a")

    /// Sun
    public static let shortWeekday = DateFormat("EEE")

    /// Sunday
    public static let weekday = DateFormat("EEEE")

    // MARK: - Month / Year

    /// May 2026
    public static let monthYear = DateFormat("MMMM yyyy")

    /// May
    public static let monthOnly = DateFormat("MMMM")

    /// May 10
    public static let monthDay = DateFormat("MMMM dd")

    /// May 10, 2026
    public static let monthDayYear = DateFormat("MMMM dd, yyyy")

    /// May 2026
    public static let shortMonthYear = DateFormat("MMM yyyy")

    // MARK: - API / Backend

    /// 20260510234512
    public static let backendTimestamp = DateFormat("yyyyMMddHHmmss", isMachineReadable: true)

    /// 2026_05_10
    public static let backendDateUnderscore = DateFormat("yyyy_MM_dd", isMachineReadable: true)

    /// 1778456712 (whole seconds since 1970)
    public static let unixTimestamp = DateFormat(kind: .unixTimestamp, isMachineReadable: true)

    /// 23-02-1993
    public static let birthday = DateFormat("dd-MM-yyyy")
}

public extension Date {
    /// Formats the date in a named format
    ///
    /// Defaults to `Region.current`'s time zone, and to its locale unless the
    /// format is machine-readable (then `Locale.posix`).
    func toString(
        _ format: DateFormat,
        timeZone: TimeZone = Region.current.timeZone,
        locale: Locale? = nil
    ) -> String {
        let locale = locale ?? (format.isMachineReadable ? .posix : Region.current.locale)
        switch format.kind {
        case .pattern(let pattern):
            return DateFormatterCache.formatter(format: pattern, locale: locale, timeZone: timeZone).string(from: self)
        case .relativeDay:
            return DateFormatterCache.relativeDayFormatter(locale: locale, timeZone: timeZone).string(from: self)
        case .unixTimestamp:
            return String(Int(timeIntervalSince1970.rounded(.down)))
        }
    }
}

public extension String {
    /// Parses a date string in a named format; always `nil` for `relativeDay`
    ///
    /// Uses `Locale.posix` by default, like `toDate(dateFormat:timeZone:)`.
    /// Formats without a zone are read in `timeZone`.
    func toDate(_ format: DateFormat, timeZone: TimeZone = .current, locale: Locale = .posix) -> Date? {
        switch format.kind {
        case .pattern(let pattern):
            return DateFormatterCache.formatter(format: pattern, locale: locale, timeZone: timeZone).date(from: self)
        case .relativeDay:
            return nil
        case .unixTimestamp:
            return TimeInterval(self).map(Date.init(timeIntervalSince1970:))
        }
    }
}
