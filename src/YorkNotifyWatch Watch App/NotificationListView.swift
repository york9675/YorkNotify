//
//  ContentView.swift
//  YorkNotifyWatch Watch App
//
//  Created by York on 2024/10/30.
//

import Foundation
import SwiftUI

struct NotificationListView: View {
    @StateObject private var connectivityManager = WatchConnectivityManager.shared
    
    private var groupedNotifications: [(Date, [WatchNotificationItem])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: connectivityManager.notifications) { notification in
            calendar.startOfDay(for: notification.time)
        }
        return grouped.sorted { $0.key < $1.key }
    }
    
    private func formatSectionHeader(_ date: Date) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        if calendar.isDate(date, inSameDayAs: today) {
            return String(localized: "Today")
        } else if calendar.isDate(date, inSameDayAs: tomorrow) {
            return String(localized: "Tomorrow")
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "EEE, MMMM d",
                                                         options: 0,
                                                         locale: Locale.current)
            return formatter.string(from: date)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if connectivityManager.notifications.isEmpty {
                    VStack {
                        Image(systemName: "bell")
                            .font(.system(size: 40))
                            .padding(.bottom, 8)
                            .foregroundStyle(.secondary)
                        
                        Text("No notifications yet")
                            .font(.headline)
                        
                        Text("Schedule notifications using your iPhone and tap ")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            + Text(Image(systemName: "arrow.triangle.2.circlepath"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            + Text(" button.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(groupedNotifications, id: \.0) { date, notifications in
                            Section(header: Text(formatSectionHeader(date))) {
                                ForEach(notifications) { notification in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(notification.title)
                                            .font(.headline)
                                        Text(notification.content)
                                            .font(.caption)
                                        Text(notification.time, style: .time)
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("List")
    }
}

#Preview {
    ContentView()
}

/*
░░░░░██████╗░░██████╗░░░░░
░░░░██╔════╝░██╔════╝░░░░░
░░░░██║░░██╗░██║░░██╗░░░░░
░░░░██║░░╚██╗██║░░╚██╗░░░░
░░░░╚██████╔╝╚██████╔╝░░░░
░░░░░╚═════╝░░╚═════╝░░░░░
*/
