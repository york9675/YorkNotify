//
//  GlobalUtils.swift
//  YorkNotify
//
//  Created by York on 2024/10/1.
//

import Foundation
import SwiftUI
import UserNotifications

let appVersion = "v" + (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown")
let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"

extension Color {
    var toHex: String? {
        guard let components = self.cgColor?.components, components.count >= 3 else {
            return nil
        }
        let r = components[0]
        let g = components[1]
        let b = components[2]
        return String(format: "%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }

    init?(hex: String) {
        let r, g, b: CGFloat
        guard hex.count == 6, let hexNumber = Int(hex, radix: 16) else { return nil }
        r = CGFloat((hexNumber >> 16) & 0xFF) / 255
        g = CGFloat((hexNumber >> 8) & 0xFF) / 255
        b = CGFloat(hexNumber & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// Update checker
class AppState: ObservableObject {
    @Published var hasCheckedForUpdates: Bool = false
    @Published var latestVersion: String? = nil
}

struct GitHubRelease: Decodable {
    let tag_name: String
}

func fetchLatestVersion(completion: @escaping (String?) -> Void) {
    guard let url = URL(string: "https://api.github.com/repos/york9675/YorkNotify/releases/latest") else {
        completion(nil)
        return
    }

    URLSession.shared.dataTask(with: url) { data, response, error in
        if let data = data {
            do {
                let release = try JSONDecoder().decode(GitHubRelease.self, from: data)
                completion(release.tag_name)
            } catch {
                completion(nil)
            }
        } else {
            completion(nil)
        }
    }.resume()
}

func isNewVersionAvailable(currentVersion: String, latestVersion: String) -> Bool {
    let currentVersion = currentVersion.replacingOccurrences(of: "v", with: "")
    let latestVersion = latestVersion.replacingOccurrences(of: "v", with: "")
    
    return latestVersion.compare(currentVersion, options: .numeric) == .orderedDescending
}

enum Theme: String, CaseIterable, Identifiable {
    case system
    case light
    case dark
    
    var localizedString: String {
        switch self {
        case .system:
            return String(localized: "System")
        case .light:
            return String(localized: "Light")
        case .dark:
            return String(localized: "Dark")
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
    
    var id: String { self.rawValue }
}

struct NotificationItem: Identifiable, Codable {
    var id = UUID()
    var title: String
    var content: String
    var time: Date
    var repeats: Bool
    var repeatFrequency: RepeatFrequency

    var customRepeatValue: Int
    var customRepeatUnit: RepeatCustomUnit
    var repeatEndCondition: RepeatEndCondition
    var repeatEndDate: Date?

    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        time: Date,
        repeats: Bool,
        repeatFrequency: RepeatFrequency,
        customRepeatValue: Int = 1,
        customRepeatUnit: RepeatCustomUnit = .day,
        repeatEndCondition: RepeatEndCondition = .never,
        repeatEndDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.time = time
        self.repeats = repeats
        self.repeatFrequency = repeatFrequency
        self.customRepeatValue = max(1, customRepeatValue)
        self.customRepeatUnit = customRepeatUnit
        self.repeatEndCondition = repeatEndCondition
        self.repeatEndDate = repeatEndDate
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case content
        case time
        case repeats
        case repeatFrequency
        case customRepeatValue
        case customRepeatUnit
        case repeatEndCondition
        case repeatEndDate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        time = try container.decode(Date.self, forKey: .time)
        repeats = try container.decodeIfPresent(Bool.self, forKey: .repeats) ?? false
        repeatFrequency = try container.decodeIfPresent(RepeatFrequency.self, forKey: .repeatFrequency) ?? .daily
        customRepeatValue = max(1, try container.decodeIfPresent(Int.self, forKey: .customRepeatValue) ?? 1)
        customRepeatUnit = try container.decodeIfPresent(RepeatCustomUnit.self, forKey: .customRepeatUnit) ?? .day
        repeatEndCondition = try container.decodeIfPresent(RepeatEndCondition.self, forKey: .repeatEndCondition) ?? .never
        repeatEndDate = try container.decodeIfPresent(Date.self, forKey: .repeatEndDate)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)
        try container.encode(time, forKey: .time)
        try container.encode(repeats, forKey: .repeats)
        try container.encode(repeatFrequency, forKey: .repeatFrequency)
        try container.encode(max(1, customRepeatValue), forKey: .customRepeatValue)
        try container.encode(customRepeatUnit, forKey: .customRepeatUnit)
        try container.encode(repeatEndCondition, forKey: .repeatEndCondition)
        try container.encodeIfPresent(repeatEndDate, forKey: .repeatEndDate)
    }
}

enum RepeatFrequency: String, CaseIterable, Identifiable, Codable {
    case hourly = "Hourly"
    case daily = "Daily"
    case weekly = "Weekly"
    case biweekly = "Every Two Weeks"
    case monthly = "Monthly"
    case custom = "Custom"
    
    var localizedString: String {
        switch self {
        case .hourly:
            return String(localized: "Every Hour")
        case .daily:
            return String(localized: "Daily")
        case .weekly:
            return String(localized: "Weekly")
        case .biweekly:
            return String(localized: "Every Two Weeks")
        case .monthly:
            return String(localized: "Monthly")
        case .custom:
            return String(localized: "Custom")
        }
    }
    
    var id: String { self.rawValue }
}

enum RepeatCustomUnit: String, CaseIterable, Identifiable, Codable {
    case minute = "Minute"
    case hour = "Hour"
    case day = "Day"
    case week = "Week"
    case month = "Month"

    var localizedString: String {
        switch self {
        case .minute:
            return String(localized: "Minute(s)")
        case .hour:
            return String(localized: "Hour(s)")
        case .day:
            return String(localized: "Day(s)")
        case .week:
            return String(localized: "Week(s)")
        case .month:
            return String(localized: "Month(s)")
        }
    }

    var id: String { self.rawValue }
}

enum RepeatEndCondition: String, CaseIterable, Identifiable, Codable {
    case never = "Never"
    case onDate = "On Date"

    var localizedString: String {
        switch self {
        case .never:
            return String(localized: "Never")
        case .onDate:
            return String(localized: "On Date")
        }
    }

    var id: String { self.rawValue }
}

enum NotificationScheduler {
    private static let requestSeparator = "__occurrence__"
    private static let maxScheduledOccurrences = 60
    private static let neverEndingFallbackYears = 1

    static func schedule(_ notification: NotificationItem, isTimeSensitive: Bool = false) {
        let center = UNUserNotificationCenter.current()
        let content = makeNotificationContent(from: notification, isTimeSensitive: isTimeSensitive)

        if let repeatingTrigger = repeatingTrigger(for: notification) {
            let request = UNNotificationRequest(
                identifier: requestIdentifier(for: notification),
                content: content,
                trigger: repeatingTrigger
            )

            center.add(request) { error in
                if let error = error {
                    print("Failed to create repeating notification: \(error.localizedDescription)")
                }
            }
            return
        }

        let dates = finiteScheduleDates(for: notification)
        guard !dates.isEmpty else {
            print("No valid notification dates to schedule for \(notification.id.uuidString)")
            return
        }

        for (index, date) in dates.enumerated() {
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let identifier: String

            if notification.repeats {
                identifier = requestIdentifier(for: notification, occurrenceIndex: index)
            } else {
                identifier = requestIdentifier(for: notification)
            }

            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            center.add(request) { error in
                if let error = error {
                    print("Failed to create notification \(identifier): \(error.localizedDescription)")
                }
            }
        }
    }

    static func removePendingRequests(for notificationId: UUID, completion: (() -> Void)? = nil) {
        let center = UNUserNotificationCenter.current()

        center.getPendingNotificationRequests { requests in
            let identifiers = requests
                .map(\.identifier)
                .filter { belongsToNotification($0, notificationId: notificationId) }

            if !identifiers.isEmpty {
                center.removePendingNotificationRequests(withIdentifiers: identifiers)
            }

            DispatchQueue.main.async {
                completion?()
            }
        }
    }

    static func requestIdentifier(for notification: NotificationItem, occurrenceIndex: Int? = nil) -> String {
        if let occurrenceIndex {
            return "\(notification.id.uuidString)\(requestSeparator)\(occurrenceIndex)"
        }
        return notification.id.uuidString
    }

    static func baseNotificationId(from requestIdentifier: String) -> UUID? {
        let baseIdentifier = requestIdentifier.components(separatedBy: requestSeparator).first ?? requestIdentifier
        return UUID(uuidString: baseIdentifier)
    }

    static func belongsToNotification(_ requestIdentifier: String, notificationId: UUID) -> Bool {
        requestIdentifier == notificationId.uuidString ||
        requestIdentifier.hasPrefix("\(notificationId.uuidString)\(requestSeparator)")
    }

    static func nextDatesByNotificationId(from requests: [UNNotificationRequest]) -> [UUID: Date] {
        var nextDates: [UUID: Date] = [:]

        for request in requests {
            guard let trigger = request.trigger as? UNCalendarNotificationTrigger,
                  let nextDate = trigger.nextTriggerDate(),
                  let notificationId = baseNotificationId(from: request.identifier) else {
                continue
            }

            if let existingDate = nextDates[notificationId] {
                nextDates[notificationId] = min(existingDate, nextDate)
            } else {
                nextDates[notificationId] = nextDate
            }
        }

        return nextDates
    }

    private static func makeNotificationContent(from notification: NotificationItem, isTimeSensitive: Bool) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.content
        content.sound = .default
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)

        if isTimeSensitive {
            content.interruptionLevel = .timeSensitive
        }

        return content
    }

    private static func repeatingTrigger(for notification: NotificationItem) -> UNNotificationTrigger? {
        guard notification.repeats, notification.repeatEndCondition == .never else {
            return nil
        }

        guard let dateComponents = repeatingDateComponents(for: notification) else {
            return nil
        }

        return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
    }

    private static func repeatingDateComponents(for notification: NotificationItem) -> DateComponents? {
        switch notification.repeatFrequency {
        case .hourly:
            return Calendar.current.dateComponents([.minute], from: notification.time)
        case .daily:
            return Calendar.current.dateComponents([.hour, .minute], from: notification.time)
        case .weekly:
            return Calendar.current.dateComponents([.weekday, .hour, .minute], from: notification.time)
        case .monthly:
            return Calendar.current.dateComponents([.day, .hour, .minute], from: notification.time)
        case .biweekly:
            return nil
        case .custom:
            let customValue = max(1, notification.customRepeatValue)
            guard customValue == 1 else {
                return nil
            }

            switch notification.customRepeatUnit {
            case .minute:
                return Calendar.current.dateComponents([.second], from: notification.time)
            case .hour:
                return Calendar.current.dateComponents([.minute], from: notification.time)
            case .day:
                return Calendar.current.dateComponents([.hour, .minute], from: notification.time)
            case .week:
                return Calendar.current.dateComponents([.weekday, .hour, .minute], from: notification.time)
            case .month:
                return Calendar.current.dateComponents([.day, .hour, .minute], from: notification.time)
            }
        }
    }

    private static func finiteScheduleDates(for notification: NotificationItem) -> [Date] {
        var scheduledDates: [Date] = []
        let now = Date()

        var currentDate = notification.time
        let upperBound: Date

        if notification.repeats {
            if notification.repeatEndCondition == .onDate,
               let endDate = notification.repeatEndDate,
               let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) {
                upperBound = endOfDay
            } else {
                upperBound = Calendar.current.date(byAdding: .year, value: neverEndingFallbackYears, to: now) ?? now
            }
        } else {
            upperBound = currentDate
        }

        while currentDate <= upperBound, scheduledDates.count < maxScheduledOccurrences {
            if currentDate >= now {
                scheduledDates.append(currentDate)
            }

            guard notification.repeats,
                  let nextDate = nextDate(after: currentDate, for: notification) else {
                break
            }

            currentDate = nextDate
        }

        return scheduledDates
    }

    private static func nextDate(after date: Date, for notification: NotificationItem) -> Date? {
        let calendar = Calendar.current

        switch notification.repeatFrequency {
        case .hourly:
            return calendar.date(byAdding: .hour, value: 1, to: date)
        case .daily:
            return calendar.date(byAdding: .day, value: 1, to: date)
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: date)
        case .biweekly:
            return calendar.date(byAdding: .weekOfYear, value: 2, to: date)
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: date)
        case .custom:
            let value = max(1, notification.customRepeatValue)
            switch notification.customRepeatUnit {
            case .minute:
                return calendar.date(byAdding: .minute, value: value, to: date)
            case .hour:
                return calendar.date(byAdding: .hour, value: value, to: date)
            case .day:
                return calendar.date(byAdding: .day, value: value, to: date)
            case .week:
                return calendar.date(byAdding: .weekOfYear, value: value, to: date)
            case .month:
                return calendar.date(byAdding: .month, value: value, to: date)
            }
        }
    }
}

#if DEBUG
extension NotificationItem {
    static var previewSample: NotificationItem {
        NotificationItem(
            title: "Team Standup",
            content: "Daily sync starts in 10 minutes.",
            time: Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date(),
            repeats: true,
            repeatFrequency: .daily,
            customRepeatValue: 1,
            customRepeatUnit: .day,
            repeatEndCondition: .never,
            repeatEndDate: nil
        )
    }
}
#endif

private func dateFromSectionTitle(_ title: String, today: Date, tomorrow: Date, dateFormatter: DateFormatter) -> Date {
    if title == "Today" {
        return today
    } else if title == "Tomorrow" {
        return tomorrow
    } else {
        return dateFormatter.date(from: title) ?? Date.distantFuture
    }
}

enum AppIcon: String, CaseIterable {
    case `default` = "AppIconDefault"
    case threeD = "AppIcon3D"
    case white = "AppIconWhite"
    case black = "AppIconBlack"
    case whiteLogo = "AppIconWhiteLogo"
    case blackLogo = "AppIconBlackLogo"

    var description: String {
        // Removing the "AppIcon" prefix for display
        if self == .default {
            return "Default"
        } else {
            return self.rawValue.replacingOccurrences(of: "AppIcon", with: "")
        }
    }
    
    var icon: Image {
        Image("\(self.rawValue)-Preview")
    }

    var name: String? {
        self == .default ? nil : self.rawValue
    }
}

class CommonUtils {
    static func updateAppIcon(with iconName: String?) {
        DispatchQueue.main.async {
            UIApplication.shared.setAlternateIconName(iconName) { error in
                if let error = error {
                    print("Could not update icon: \(error)")
                } else {
                    print("Icon updated successfully to: \(iconName ?? "default")")
                }
            }
        }
    }
}

extension View {
    @ViewBuilder
    func liquidGlassTabBehavior() -> some View {
        if #available(iOS 26.0, *) {
            self
                .tabViewStyle(.sidebarAdaptable)
                .tabBarMinimizeBehavior(.onScrollDown)
        } else {
            self
        }
    }

    @ViewBuilder
    func liquidGlassProminentButtonIfAvailable() -> some View {
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glassProminent)
        } else {
            self
        }
    }

    @ViewBuilder
    func liquidGlassButtonIfAvailable() -> some View {
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glass)
        } else {
            self
        }
    }
}

/*
░░░░░██████╗░░██████╗░░░░░
░░░░██╔════╝░██╔════╝░░░░░
░░░░██║░░██╗░██║░░██╗░░░░░
░░░░██║░░╚██╗██║░░╚██╗░░░░
░░░░╚██████╔╝╚██████╔╝░░░░
░░░░░╚═════╝░░╚═════╝░░░░░
*/
