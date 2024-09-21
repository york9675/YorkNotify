//
//  ContentView.swift
//  YorkNotify
//
//  Created by York on 2024/6/28.
//

import SwiftUI
import UserNotifications

let appVersion = "v2.0.0-beta"
let build = "25"

struct ContentView: View {
    @AppStorage("selectedTheme") private var selectedTheme: String = Theme.system.rawValue

    var body: some View {

        TabView {
            HomeTabView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            SettingsTabView(selectedTheme: Binding(
                get: { Theme(rawValue: selectedTheme) ?? .system },
                set: { selectedTheme = $0.rawValue }
            ))
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .preferredColorScheme(Theme(rawValue: selectedTheme)?.colorScheme)
    }
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

struct HomeTabView: View {
    @State private var notifications: [NotificationItem] = []
    @State private var showingCreateView = false
    @State private var sortOrder: SortOrder = .time
    @State private var searchText = ""
    @State private var notificationToDelete: NotificationItem?
    @State private var greetingTitle: String = "Home"
    
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
    
    private func refreshNotifications() {
        loadNotifications()
        updateGreeting()
        checkNotificationSettings()
    }

    var body: some View {
        NavigationView {
            VStack {
                if notifications.isEmpty {
                    VStack {
                        Image(systemName: "bell")
                            .padding(.bottom, 5)
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("No notification yet")
                            .font(.headline)
                        Text("Tap \"+\" above to schedule notifications.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(searchResults) { notification in
                            NavigationLink(destination: EditNotificationView(notification: notification, notifications: $notifications)) {
                                VStack(alignment: .leading) {
                                    Text(notification.title)
                                        .font(.headline)
                                    Text(notification.content)
                                        .font(.body)
                                    HStack {
                                        Text(notification.time, style: .date)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        Text(notification.time, style: .time)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
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
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search Notifications")
            .refreshable {
                refreshNotifications()
            }
            .onAppear {
                refreshNotifications()
            }
            .onAppear(perform: checkForUpdatesOnce)
            .navigationTitle(greetingTitle)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Section("Sort by...") {
                            Button(action: {
                                sortOrder = .time
                            }) {
                                Label("Time", systemImage: "clock")
                            }
                            Button(action: {
                                sortOrder = .alphabetical
                            }) {
                                Label("A-Z", systemImage: "character")
                            }
                        }
                    } label: {
                        Label("Sort by...", systemImage: "ellipsis.circle")
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
        if let data = UserDefaults.standard.data(forKey: "savedNotifications"),
           let decodedNotifications = try? JSONDecoder().decode([NotificationItem].self, from: data) {
            self.notifications = decodedNotifications
        }
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let currentIds = requests.map { $0.identifier }
            DispatchQueue.main.async {
                self.notifications.removeAll { !currentIds.contains($0.id.uuidString) }
                self.saveNotifications()
            }
        }
    }

    private func saveNotifications() {
        if let encodedData = try? JSONEncoder().encode(notifications) {
            UserDefaults.standard.set(encodedData, forKey: "savedNotifications")
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

struct CreateNotificationView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var notifications: [NotificationItem]
    
    @State private var title = ""
    @State private var content = ""
    @State private var time = Calendar.current.date(byAdding: .minute, value: 5, to: Date()) ?? Date()
    @State private var repeats = false
    @State private var repeatFrequency: RepeatFrequency = .daily
    @State private var isValid = false
    @State private var isTimeSensitive = false
    
    @State private var alertMessage = ""
    
    enum ActiveAlert: Identifiable {
        case warning, proceedWithDefault

        var id: String {
            switch self {
            case .warning: return "warning"
            case .proceedWithDefault: return "proceedWithDefault"
            }
        }
    }
    
    @State private var activeAlert: ActiveAlert? = nil

    @AppStorage("defaultNotificationTitle") private var defaultTitle: String = "York Notify"
    @AppStorage("defaultNotificationContent") private var defaultContent: String = "Please remember."
    @AppStorage("showMissingInfoAlert") private var showMissingInfoAlert = true
    @AppStorage("enableTimeSensitiveNotifications") private var enableTimeSensitiveNotifications = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Notification Content")) {
                    TextField("Notification Title", text: $title)
                        .onChange(of: title) { _ in updateValidity() }
                    
                    TextField("Notification Text", text: $content)
                        .onChange(of: content) { _ in updateValidity() }
                }
                Section(header: Text("Notification Settings")) {
                    DatePicker("Time", selection: $time, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                        .onChange(of: time) { _ in updateValidity() }
                    Toggle("Repeat", isOn: $repeats)
                    if repeats {
                        Picker("Frequency", selection: $repeatFrequency) {
                            ForEach(RepeatFrequency.allCases) { frequency in
                                Text(frequency.localizedString).tag(frequency)
                            }
                        }
                    }
                    if enableTimeSensitiveNotifications {
                        Toggle("Time Sensitive Notifications", isOn: $isTimeSensitive)
                    }
                }
            }
            .navigationTitle("Create Notification")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if title.isEmpty || content.isEmpty {
                            handleMissingInfo()
                        } else if isValid {
                            saveNotification()
                        } else {
                            activeAlert = .warning
                        }
                    }) {
                        Text("Save").bold()
                    }
                }
            }
            .alert(item: $activeAlert) { alertType in
                switch alertType {
                case .warning:
                    return Alert(
                        title: Text("Warning"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                    
                case .proceedWithDefault:
                    return Alert(
                        title: Text("Missing Information"),
                        message: Text("You haven't filled out all fields. The default content will be used for the missing fields. Do you want to proceed?"),
                        primaryButton: .destructive(Text("Proceed")) {
                            if title.isEmpty {
                                title = defaultTitle
                            }
                            if content.isEmpty {
                                content = defaultContent
                            }
                            saveNotification()
                        },
                        secondaryButton: .cancel(Text("Cancel"))
                    )
                }
            }
        }
        .onAppear {
            updateValidity()
        }
    }
    
    private func saveNotification() {
        let newNotification = NotificationItem(
            title: title,
            content: content,
            time: time,
            repeats: repeats,
            repeatFrequency: repeatFrequency
        )
        notifications.append(newNotification)
        scheduleNotification(notification: newNotification)
        saveNotifications()
        presentationMode.wrappedValue.dismiss()
    }

    private func saveNotifications() {
        if let encodedData = try? JSONEncoder().encode(notifications) {
            UserDefaults.standard.set(encodedData, forKey: "savedNotifications")
        }
    }

    private func isValidTime() -> Bool {
        return time > Date()
    }

    private func updateValidity() {
        if title.isEmpty || content.isEmpty {
            isValid = false
            alertMessage = "Please fill in the notification title and text."
        } else if !isValidTime() {
            isValid = false
            alertMessage = "Please select a time in the future."
        } else {
            isValid = true
        }
    }
    
    private func handleMissingInfo() {
        if showMissingInfoAlert {
            activeAlert = .proceedWithDefault
        } else {
            if title.isEmpty {
                title = defaultTitle
            }
            if content.isEmpty {
                content = defaultContent
            }
            saveNotification()
        }
    }

    func scheduleNotification(notification: NotificationItem) {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.content
        content.sound = .default
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)

        if isTimeSensitive {
            content.interruptionLevel = .timeSensitive
        }

        var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notification.time)
        if notification.repeats {
            switch notification.repeatFrequency {
            case .daily:
                dateComponents = Calendar.current.dateComponents([.hour, .minute], from: notification.time)
            case .weekly:
                dateComponents = Calendar.current.dateComponents([.weekday, .hour, .minute], from: notification.time)
            }
        }

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: notification.repeats)
        let request = UNNotificationRequest(identifier: notification.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to create notification \(error.localizedDescription)")
            }
        }
    }
}

struct EditNotificationView: View {
    @State var notification: NotificationItem
    @Binding var notifications: [NotificationItem]
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isValid = false

    enum ActiveAlert: Identifiable {
        case delete, warning, proceedWithDefault

        var id: String {
            switch self {
            case .delete:
                return "delete"
            case .warning:
                return "warning"
            case .proceedWithDefault:
                return "proceedWithDefault"
            }
        }
    }
    
    @State private var activeAlert: ActiveAlert? = nil

    @AppStorage("defaultNotificationTitle") private var defaultTitle: String = "YorkNotift"
    @AppStorage("defaultNotificationContent") private var defaultContent: String = "Please remember."
    @AppStorage("showMissingInfoAlert") private var showMissingInfoAlert = true

    var body: some View {
        Form {
            Section(header: Text("Notification Content")) {
                TextField("Notification Title", text: $notification.title)
                    .onChange(of: notification.title) { _ in updateValidity() }
                TextField("Notification Text", text: $notification.content)
                    .onChange(of: notification.content) { _ in updateValidity() }
            }
            Section(header: Text("Notification Settings")) {
                DatePicker("Time", selection: $notification.time, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                    .onChange(of: notification.time) { _ in updateValidity() }
                Toggle("Repeat", isOn: $notification.repeats)
                if notification.repeats {
                    Picker("Frequency", selection: $notification.repeatFrequency) {
                        ForEach(RepeatFrequency.allCases) { frequency in
                            Text(frequency.localizedString).tag(frequency)
                        }
                    }
                }
            }
            
            Button(action: {
                if notification.title.isEmpty || notification.content.isEmpty {
                    handleMissingInfo()
                } else if isValid {
                    saveNotification()
                } else {
                    activeAlert = .warning
                }
            }) {
                Text("Save").bold()
            }
        }
        .navigationTitle("Edit Notification")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    activeAlert = .delete
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .alert(item: $activeAlert) { alertType in
            switch alertType {
            case .delete:
                return Alert(
                    title: Text("Warning"),
                    message: Text("Are you sure you want to delete the scheduled notification \"\(notification.title)\"?\nThis operation cannot be undone"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
                            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification.id.uuidString])
                            notifications.remove(at: index)
                        }
                        presentationMode.wrappedValue.dismiss()
                    },
                    secondaryButton: .cancel(Text("Cancel"))
                )
                
            case .warning:
                return Alert(
                    title: Text("Warning"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
                
            case .proceedWithDefault:
                return Alert(
                    title: Text("Missing Information"),
                    message: Text("You haven't filled out all fields. The default content will be used for the missing fields. Do you want to proceed?"),
                    primaryButton: .destructive(Text("Proceed")) {
                        if notification.title.isEmpty {
                            notification.title = defaultTitle
                        }
                        if notification.content.isEmpty {
                            notification.content = defaultContent
                        }
                        saveNotification()
                    },
                    secondaryButton: .cancel(Text("Cancel"))
                )
            }
        }
        .onAppear {
            updateValidity()
        }
    }
    
    private func saveNotification() {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index] = notification
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification.id.uuidString])
            scheduleNotification(notification: notification)
            saveNotifications()
        }
        presentationMode.wrappedValue.dismiss()
    }

    private func saveNotifications() {
        if let encodedData = try? JSONEncoder().encode(notifications) {
            UserDefaults.standard.set(encodedData, forKey: "savedNotifications")
        }
    }

    private func isValidTime() -> Bool {
        return notification.time > Date()
    }

    private func updateValidity() {
        if notification.title.isEmpty && notification.content.isEmpty {
            isValid = false
            alertMessage = "Please fill in the notification title and text."
        } else if !isValidTime() {
            isValid = false
            alertMessage = "Please select a time in the future."
        } else {
            isValid = true
        }
    }

    private func handleMissingInfo() {
        if showMissingInfoAlert {
            activeAlert = .proceedWithDefault
        } else {
            // Automatically use default values without showing the alert
            if notification.title.isEmpty {
                notification.title = defaultTitle
            }
            if notification.content.isEmpty {
                notification.content = defaultContent
            }
            saveNotification()
        }
    }

    func scheduleNotification(notification: NotificationItem) {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.content
        content.sound = .default
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)

        var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notification.time)
        if notification.repeats {
            switch notification.repeatFrequency {
            case .daily:
                dateComponents = Calendar.current.dateComponents([.hour, .minute], from: notification.time)
            case .weekly:
                dateComponents = Calendar.current.dateComponents([.weekday, .hour, .minute], from: notification.time)
            }
        }

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: notification.repeats)
        let request = UNNotificationRequest(identifier: notification.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

struct SettingsTabView: View {
    @Binding var selectedTheme: Theme
    @State private var showErrorAlert = false
    @Environment(\.openURL) private var openURL
    
    //    @State private var showWarning = true
    
    var body: some View {
        NavigationView {
            Form {
                
                Section(header: Text("General")) {
                    
                    Picker(selection: $selectedTheme, label: Label("Theme", systemImage: "moon")) {
                        ForEach(Theme.allCases) { theme in
                            Text(theme.localizedString).tag(theme)
                        }
                    }
                    
                    NavigationLink(destination: DefaultContentView()) {
                        HStack {
                            Label("Default Content", systemImage: "character")
                        }
                    }
                    
                    NavigationLink(destination: IconView()) {
                        HStack {
                            Label("App Icon", systemImage: "square.grid.2x2")
                        }
                    }
                    
                    NavigationLink(destination: LangView()) {
                        HStack {
                            Label("Language", systemImage: "globe")
                        }
                    }
                }
                
                Section {
                    NavigationLink(destination: LabView()) {
                        HStack {
                            Label("Lab", systemImage: "flask")
                                .foregroundColor(Color.purple)
                        }
                    }
                }
                
                Section(header: Text("About"), footer: Text("2024 York Development")) {
                    NavigationLink(destination: HelpView()) {
                        HStack {
                            Label("Help", systemImage: "questionmark.circle")
                        }
                    }
                    
                    NavigationLink(destination: AutherView()) {
                        HStack {
                            Label("Auther", systemImage: "person")
                            Spacer()
                            Text("York")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    NavigationLink(destination: VersionView()) {
                        HStack {
                            Label("Version", systemImage: "info.circle")
                            Spacer()
                            Text("\(appVersion) (\(build))")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Button(action: {
                        if let url = URL(string: "https://forms.gle/o1hFjy4q98Ua1H7L7") {
                            openURL(url)
                        }
                    }) {
                        HStack {
                            Label("Feedback", systemImage: "info.bubble")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                        }
                    }
                }
                
//              // Warning MSG
//                if showWarning {
//                    VStack(alignment: .leading, spacing: 5) {
//                        HStack {
//                            Label {
//                                Text("Warning")
//                                    .font(.headline)
//                            } icon: {
//                                Image(systemName: "exclamationmark.triangle").foregroundColor(.red)
//                            }
//                            Spacer()
//                            Button(action: {
//                                showWarning = false
//                            }) {
//                                Image(systemName: "xmark")
//                                    .foregroundColor(.gray)
//                                    .padding(.trailing)
//                            }
//                        }
//                        
//                        Text("TEXT")
//                            .font(.footnote)
//                        
//                    }
//                    .padding(.vertical, 5)
//                }
                
            }
            .navigationTitle("Settings")
        }
    }
}

struct VersionView: View {
    @Environment(\.openURL) private var openURL
    
    @AppStorage("autoCheckUpdates") private var autoCheckUpdates = true
    
    var body: some View {
        Form {
            
            Section {
                VStack {
                    Image(systemName: "info.circle.fill")
                        .resizable()
                        .foregroundColor(Color.blue)
                        .frame(width: 30, height: 30)
                        .aspectRatio(contentMode: .fit)
                    
                    Text("Version")
                        .font(.title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Access comprehensive details about the current software version, including a complete update log outlining new features, improvements, and bug fixes.\n\nAdditionally, you can easily report bugs using the button below.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }

            Section(header: Text("Update Log")) {
                Text("• New \"Default Content\" feature\n• Add notification list refresh button\n• Add \"Lab\"\n• Add the ability to automatically check for updates from GitHub\n• Some interface changes were made to be more in line with Apple’s design style (I may have accidentally learned Apple’s bug-increasing techniques in the process XD)\n• Other minor modifications and bug fixes")
            }
            
            Section(footer: Text("When enabled, this app will automatically check if new updates are available from GitHub on startup.")) {
                Toggle("Check for Updates Automatically", isOn: $autoCheckUpdates)
                    .onChange(of: autoCheckUpdates) { value in
                        UserDefaults.standard.set(value, forKey: "autoCheckUpdates")
                    }
            }
            
            Section {
                Button(action: {
                    if let url = URL(string: "https://forms.gle/o1hFjy4q98Ua1H7L7") {
                        openURL(url)
                    }
                }) {
                    HStack {
                        Label("Bug Report", systemImage: "exclamationmark.triangle")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .navigationTitle(appVersion)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DefaultContentView: View {
    @AppStorage("defaultNotificationTitle") private var defaultTitle: String = "York Notify"
    @AppStorage("defaultNotificationContent") private var defaultContent: String = "Please remember."
    @AppStorage("showMissingInfoAlert") private var showMissingInfoAlert = true

    private let originalDefaultTitle = "York Notify"
    private let originalDefaultContent = "Please remember."

    var body: some View {
        Form {
            
            Section {
                VStack {
                    Image(systemName: "character")
                        .font(.largeTitle)
                        .foregroundColor(Color.blue)
                    
                    Text("Default Content")
                        .font(.title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Set the default notification content here.\n\nWhenever you create a new notification but leave certain fields empty, the app will automatically insert the default content you've defined here. This ensures that all notifications are complete and consistent, even if specific details are missing during creation.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
            
            Section(header: Text("Default Notification Content")) {
                HStack {
                    Text("Default Title")
                    TextField("Title", text: $defaultTitle)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("Default Text")
                    TextField("Text", text: $defaultContent)
                        .multilineTextAlignment(.trailing)
                }
                
                Button(action: {
                    resetToDefault()
                }) {
                    HStack {
                        Label("Reset", systemImage: "arrow.triangle.2.circlepath")
                    }
                }
            }
            
            Section(header: Text("Alert"), footer: Text("If disabled, the default content will be automatically used without warning when creating notifications if information is missing.")) {
                Toggle("Show missing information alert", isOn: $showMissingInfoAlert)
            }
        }
        .navigationTitle("Default Content")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func resetToDefault() {
        defaultTitle = originalDefaultTitle
        defaultContent = originalDefaultContent
    }
}

struct LabView: View {
    @AppStorage("enableExperimentalFeatures") private var enableExperimentalFeatures = false
    @AppStorage("enableTimeSensitiveNotifications") private var enableTimeSensitiveNotifications = false

    var body: some View {
        Form {
            Section {
                VStack {
                    Image(systemName: "flask.fill")
                        .font(.largeTitle)
                        .foregroundColor(Color.purple)
                    
                    Text("Lab")
                        .font(.title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Enable Experimental Features to try out new, unfinished features that may not work as expected.\n\nThese features are in testing and could change or be removed in future updates. Use with caution, and expect occasional issues.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                Toggle("Enable Experimental Features", isOn: Binding(
                    get: { enableExperimentalFeatures },
                    set: { newValue in
                        enableExperimentalFeatures = newValue
                        if !newValue {
                            enableTimeSensitiveNotifications = false
                        }
                    }
                ))
            }

            if enableExperimentalFeatures {
                Section(header: Text("Available Features")) {
                    HStack {
                        Image(systemName: "clock.fill")
                            .font(.largeTitle)
                            .foregroundColor(Color.yellow)
                        
                        VStack(alignment: .leading) {
                            Text("Time Sensitive Notifications")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Text("Time Sensitive Notifications are a special category of alerts that can break through Focus modes or Do Not Disturb settings to deliver important information. When enabled, notifications marked as \"Time Sensitive Notifications\" will be treated with higher urgency and will be shown to the user even when their device is otherwise set to minimize interruptions.")
                                .font(.subheadline)
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                    
                    Toggle("Enable", isOn: $enableTimeSensitiveNotifications)
                }
            }
        }
        .navigationTitle("Lab")
        .navigationBarTitleDisplayMode(.inline)
    }
}


struct LangView: View {
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        Form {
            Section {
                VStack {
                    Image(systemName: "globe")
                        .resizable()
                        .foregroundColor(Color.blue)
                        .frame(width: 30, height: 30)
                        .aspectRatio(contentMode: .fit)
                    
                    Text("Language")
                        .font(.title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Please click the button below to jump to the system settings and tap \"Language\" to change your preferred App language.\n\nThe translation may use a large amount of machine translation and contain many errors or irrationalities. If there are any errors in the translation, please go to the feedback form to report it. Thank you!")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                Button(action: {
                    let url = URL(string: UIApplication.openSettingsURLString)!
                    UIApplication.shared.open(url)
                }) {
                    HStack {
                        Label("App Settings", systemImage: "gear")
                    }
                }
                Button(action: {
                    if let url = URL(string: "https://forms.gle/o1hFjy4q98Ua1H7L7") {
                        openURL(url)
                    }
                }) {
                    HStack {
                        Label("Translation problem report", systemImage: "exclamationmark.triangle")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .navigationTitle("Language")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct HelpView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        Form{
            Section {
                VStack {
                    Image(systemName: "questionmark.circle.fill")
                        .resizable()
                        .foregroundColor(Color.blue)
                        .frame(width: 30, height: 30)
                        .aspectRatio(contentMode: .fit)
                    
                    Text("Help Center")
                        .font(.title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Welcome to the Help Center!\n\nHere, you’ll find everything you need to get the most out of this app. Whether you’re a first-time user or an experienced pro, our Help Center offers guides, tutorials, and troubleshooting tips. Browse through our comprehensive FAQs for additional support. If you need further assistance, don’t hesitate to fill the report form.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
            Section(header: Text("Q: How to schedule notifications?")) {
                Text("Tap the \"+\" symbol in the upper right corner of the home tab, enter the notification title and content, finally set the time and click Save to schedule the notification.")
            }
            Section(header: Text("Q: Any other questions?")) {
                Text("Use our feedback form to get help!")
            }
            Section {
                Button(action: {
                    if let url = URL(string: "https://forms.gle/o1hFjy4q98Ua1H7L7") {
                        openURL(url)
                    }
                }) {
                    HStack {
                        Label("Bug Report", systemImage: "exclamationmark.triangle")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .navigationTitle("Help Center")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AutherView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        Form {
            Text("The developer of this app!")
            Section(header: Text("Links")) {
                Button(action: {
                    if let url = URL(string: "https://github.com/york9675") {
                        openURL(url)
                    }
                }) {
                    HStack {
                        Label("GitHub", systemImage: "cat")
                    }
                }
            }
            Section(header: Text("Donate")) {
                Button(action: {
                    if let url = URL(string: "https://www.buymeacoffee.com/york0524") {
                        openURL(url)
                    }
                }) {
                    HStack {
                        Label("Buy Me A Coffee", systemImage: "cup.and.saucer")
                    }
                }
            }
        }
        .navigationTitle("York")
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

struct IconView: View {
    @State private var selectedIcon: AppIcon = .default
    
    var body: some View {
        List {
            Section {
                VStack {
                    Image(systemName: "square.grid.2x2.fill")
                        .resizable()
                        .foregroundColor(Color.blue)
                        .frame(width: 30, height: 30)
                        .aspectRatio(contentMode: .fit)
                    
                    Text("App Icon")
                        .font(.title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Here, you have the option to personalize your app experience by selecting your preferred app icon.\n\nChoose from a variety of available icons to customize the look and feel of the app on your device. Once you've made your selection, the app icon will automatically update, reflecting your choice instantly. This allows you to tailor your app's appearance to match your personal style or preferences, giving you more control over your user experience.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
            Section(header: Text("Select the app icon you want to change")) {
                ForEach(AppIcon.allCases, id: \.self) { icon in
                    Button(action: {
                        selectedIcon = icon
                        updateIcon()
                    }) {
                        HStack {
                            icon.icon
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            Text(icon.description)
                                .font(.body)
                            Spacer()
                            if selectedIcon == icon {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color.blue)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        .navigationTitle("App Icon")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            getCurrentIcon()
        }
    }
    
    private func getCurrentIcon() {
        if let iconName = UIApplication.shared.alternateIconName {
            selectedIcon = AppIcon(rawValue: iconName) ?? .default
        } else {
            selectedIcon = .default
        }
    }
    
    private func updateIcon() {
        print("Attempting to update icon to: \(selectedIcon.name ?? "default")")
        CommonUtils.updateAppIcon(with: selectedIcon.name)
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
