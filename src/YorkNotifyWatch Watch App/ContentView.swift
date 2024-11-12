//
//  ContentView.swift
//  YorkNotifyWatch Watch App
//
//  Created by York on 2024/10/30.
//
import SwiftUI

struct ContentView: View {
    @StateObject private var connectivityManager = WatchConnectivityManager.shared
    
    @State private var greetingTitle: String = "Notifications"
    
    private func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
            case 5..<12:
                greetingTitle = String(localized: "Good morning")
            case 12..<18:
                greetingTitle = String(localized: "Good afternoon")
            default:
                greetingTitle = String(localized: "Good night")
        }
    }
    
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
                        
                        Text("Schedule notifications using your iPhone.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
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
            .onAppear {
                updateGreeting()
            }
            .navigationTitle(greetingTitle)
        }
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
