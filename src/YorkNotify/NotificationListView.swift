//
//  NotificationListView.swift
//  YorkNotify
//
//  Created by York on 2024/10/1.
//

import Foundation
import WatchConnectivity
import SwiftUI

struct NotificationListView: View {
    @StateObject private var connectivityManager = PhoneConnectivityManager.shared
    
    @State private var notifications: [NotificationItem] = []
    @State private var showingCreateView = false
    @State private var sortOrder: SortOrder = .time
    @State private var searchText = ""
    @State private var notificationToDelete: NotificationItem?
    @State private var greetingTitle: String = "Notification List"
    @AppStorage("groupByDate") private var groupByDate: Bool = true
    
    @State private var latestVersion: String?
    
    @EnvironmentObject var appState: AppState

    enum ActiveAlert: Identifiable {
        case delete, settings, update
        
        var id: String {
            switch self {
            case .delete: return "delete"
            case .settings: return "settings"
            case .update: return "update"
            }
        }
    }
    
    @State private var activeAlert: ActiveAlert? = nil

    enum SortOrder: String, CaseIterable, Identifiable {
        case time = "Time"
        case alphabetical = "A-Z"

        var localizedString: String {
            switch self {
            case .time:
                return String(localized: "Time")
            case .alphabetical:
                return String(localized: "A-Z")
            }
        }
        
        var id: String { self.rawValue }
    }

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
    
    private func checkNotificationSettings() {
        let current = UNUserNotificationCenter.current()
        current.getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .denied {
                    activeAlert = .settings
                }
            }
        }
    }
    
    private var groupedNotifications: [(Date, [NotificationItem])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: searchResults) { notification in
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
            formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "EEE, MMMM d", options: 0, locale: Locale.current)
            return formatter.string(from: date)
        }
    }
    
    private func refreshNotifications() {
        loadNotifications()
        updateGreeting()
        checkNotificationSettings()
    }
    
    @ViewBuilder
    private func notificationRow(for notification: NotificationItem) -> some View {
        NavigationLink(destination: EditNotificationView(notification: notification, notifications: $notifications)) {
            VStack(alignment: .leading) {
                Text(notification.title)
                    .font(.headline)
                Text(notification.content)
                    .font(.body)
                Text(groupByDate ?
                     notification.time.formatted(date: .omitted, time: .shortened) :
                     notification.time.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button {
                notificationToDelete = notification
                activeAlert = .delete
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .tint(.red)
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                if notifications.isEmpty {
                    VStack {
                        Image(systemName: "bell")
                            .padding(.bottom, 5)
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No notifications yet")
                            .font(.headline)
                        Text("Tap \"+\" above to schedule notifications.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    List {
                        if groupByDate {
                            ForEach(groupedNotifications, id: \.0) { date, notifications in
                                Section(header: Text(formatSectionHeader(date))) {
                                    ForEach(notifications) { notification in
                                        notificationRow(for: notification)
                                    }
                                }
                            }
                        } else {
                            ForEach(searchResults) { notification in
                                notificationRow(for: notification)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search Notifications")
            .refreshable {
                refreshNotifications()
            }
            .onAppear {
                refreshNotifications()
                NotificationCenter.default.addObserver(
                    forName: NSNotification.Name("SyncNotificationsToWatch"),
                    object: nil,
                    queue: .main
                ) { _ in
                    connectivityManager.syncNotifications(notifications)
                }
            }
            .onAppear(perform: checkForUpdatesOnce)
            .navigationTitle(greetingTitle)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Section(header: Text("Sort by...")) {
                            Picker(selection: $sortOrder, label: Text("Sort by...")) {
                                ForEach(SortOrder.allCases) { sort in
                                    Label(sort.localizedString, systemImage: sort == .time ? "clock" : "character")
                                        .tag(sort)
                                }
                            }
                        }

                        Toggle(isOn: $groupByDate) {
                            Label("Group by Date", systemImage: "calendar")
                        }

                    } label: {
                        Label("Sort by...", systemImage: "arrow.up.arrow.down.circle")
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        refreshNotifications()
                    }) {
                        Label("Refresh", systemImage: "arrow.triangle.2.circlepath")
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showingCreateView = true
                    }) {
                        Label("Create Notification", systemImage: "plus")
                    }
                    .sheet(isPresented: $showingCreateView) {
                        CreateNotificationView(notifications: $notifications)
                    }
                }
            }
            .alert(item: $activeAlert) { alertType in
                switch alertType {
                case .delete:
                    return Alert(
                        title: Text("Warning"),
                        message: Text("Are you sure you want to delete the scheduled notification \"\(notificationToDelete?.title ?? "")\"?\nThis operation cannot be undone"),
                        primaryButton: .destructive(Text("Delete")) {
                            if let notification = notificationToDelete,
                               let index = notifications.firstIndex(where: { $0.id == notification.id }) {
                                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification.id.uuidString])
                                notifications.remove(at: index)
                            }
                        },
                        secondaryButton: .cancel(Text("Cancel"))
                    )
                    
                case .settings:
                    return Alert(
                        title: Text("No permission to send notifications!"),
                        message: Text("Please go to the system settings to allow notifications, otherwise this app will not work as expected.\n(Don’t worry, we won’t send junk notifications!)"),
                        dismissButton: .default(Text("Settings")) {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                    )
                    
                case .update:
                    return Alert(
                        title: Text("Update Available"),
                        message: Text("A new version \(appState.latestVersion ?? "unknown") is available, go to GitHub to download and install the latest version."),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
    }
    
    private func loadNotifications() {
        var loadedNotifications: [NotificationItem] = []
        
        if let data = UserDefaults.standard.data(forKey: "savedNotifications"),
           let decoded = try? JSONDecoder().decode([NotificationItem].self, from: data) {
            loadedNotifications = decoded
        }

        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let activeIds = requests.map { $0.identifier }

            var active: [NotificationItem] = []
            var history: [NotificationItem] = loadNotificationHistory()

            for notification in loadedNotifications {
                if activeIds.contains(notification.id.uuidString) {
                    active.append(notification)
                } else {
                    // Expired — move to history
                    if !history.contains(where: { $0.id == notification.id }) {
                        history.append(notification)
                    }
                }
            }

            DispatchQueue.main.async {
                self.notifications = active
                saveNotifications(active)
                saveNotifications(history, key: "notificationHistory")
                saveNotificationHistory(history)
            }
        }
    }

    private func loadNotificationHistory() -> [NotificationItem] {
        if let data = UserDefaults.standard.data(forKey: "notificationHistory"),
           let decoded = try? JSONDecoder().decode([NotificationItem].self, from: data) {
            return decoded
        }
        return []
    }

    private func saveNotificationHistory(_ history: [NotificationItem]) {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: "notificationHistory")
        }
    }

    private func saveNotifications(_ list: [NotificationItem], key: String = "savedNotifications") {
        if let encodedData = try? JSONEncoder().encode(list) {
            UserDefaults.standard.set(encodedData, forKey: key)
        }
        if key == "savedNotifications" {
            connectivityManager.syncNotifications(list)
        }
    }
    
    private var sortedNotifications: [NotificationItem] {
        switch sortOrder {
        case .time:
            return notifications.sorted { $0.time < $1.time }
        case .alphabetical:
            return notifications.sorted { $0.title < $1.title }
        }
    }

    private var searchResults: [NotificationItem] {
        if searchText.isEmpty {
            return sortedNotifications
        } else {
            return sortedNotifications.filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.content.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    private func checkForUpdatesOnce() {
        if !appState.hasCheckedForUpdates, UserDefaults.standard.bool(forKey: "autoCheckUpdates") {
            fetchLatestVersion { latest in
                DispatchQueue.main.async {
                    if let latest = latest {
                        if isNewVersionAvailable(currentVersion: appVersion, latestVersion: latest) {
                            appState.latestVersion = latest
                            activeAlert = .update
                        }
                    }
                    appState.hasCheckedForUpdates = true
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
