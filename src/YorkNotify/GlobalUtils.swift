//
//  GlobalUtils.swift
//  YorkNotify
//
//  Created by York on 2024/10/1.
//

import Foundation
import SwiftUI
import UserNotifications

let appVersion = "v" + (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown") + "-beta"
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
}

enum RepeatFrequency: String, CaseIterable, Identifiable, Codable {
    case daily = "Daily"
    case weekly = "Weekly"
    
    var localizedString: String {
        switch self {
        case .daily:
            return String(localized: "Daily")
        case .weekly:
            return String(localized: "Weekly")
        }
    }
    
    var id: String { self.rawValue }
}

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

/*
░░░░░██████╗░░██████╗░░░░░
░░░░██╔════╝░██╔════╝░░░░░
░░░░██║░░██╗░██║░░██╗░░░░░
░░░░██║░░╚██╗██║░░╚██╗░░░░
░░░░╚██████╔╝╚██████╔╝░░░░
░░░░░╚═════╝░░╚═════╝░░░░░
*/
