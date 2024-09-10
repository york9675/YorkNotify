//
//  ContentView.swift
//  YorkNotify
//
//  Created by York on 2024/6/28.
//

import SwiftUI
import UserNotifications

let appVersion = "Beta 1.2.5"
let build = "16"

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

struct HomeTabView: View {
    @State private var notifications: [NotificationItem] = []
    @State private var showingCreateView = false
    @State private var sortOrder: SortOrder = .time
    @State private var searchText = ""
    @State private var showDeleteAlert = false
    @State private var notificationToDelete: NotificationItem?
    @State private var greetingTitle: String = "Home"
    @State private var showSettingsAlert = false
    
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
                    print("No permission to send notifications.")
                    showSettingsAlert = true
                }
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack {

                if notifications.isEmpty {
                    VStack() {
                        Image(systemName: "bell")
                            .padding(.bottom, 5.0)
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("No notification yet")
                            .font(.headline)
                            .foregroundColor(.gray)
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
                                    showDeleteAlert = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.red)
                            }
                            .alert(isPresented: $showDeleteAlert) {
                                Alert(
                                    title: Text("Warning"),
                                    message: Text("Are you sure you want to delete the scheduled notification\"\(notificationToDelete?.title ?? "")\"?\nThis operation cannot be undone"),
                                    primaryButton: .destructive(Text("Delete")) {
                                        if let notification = notificationToDelete,
                                           let index = notifications.firstIndex(where: { $0.id == notification.id }) {
                                            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification.id.uuidString])
                                            notifications.remove(at: index)
                                        }
                                    },
                                    secondaryButton: .cancel(Text("Cancel"))
                                )
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search Notifications")
            .onAppear {
                loadNotifications()
                updateGreeting()
                checkNotificationSettings()
            }
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
                        showingCreateView = true
                    }) {
                        Label("Create Notification", systemImage: "plus")
                    }
                    .sheet(isPresented: $showingCreateView) {
                        CreateNotificationView(notifications: $notifications)
                    }
                }
                
            }
            .alert(isPresented: $showSettingsAlert) {
                Alert(
                    title: Text("No permission to send notifications!"),
                    message: Text("Please go to the system settings to allow notifications, otherwise this app will not work as expected.\n(Don’t worry, we won’t send junk notifications!)"),
                    dismissButton: .default(Text("Settings")) {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                )
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
    @State private var time = Calendar.current.date(byAdding: .minute, value: 1, to: Date()) ?? Date()
    @State private var repeats = false
    @State private var repeatFrequency: RepeatFrequency = .daily
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isValid = false
    
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
                        if isValid {
                            let newNotification = NotificationItem(title: title, content: content, time: time, repeats: repeats, repeatFrequency: repeatFrequency)
                            notifications.append(newNotification)
                            scheduleNotification(notification: newNotification)
                            saveNotifications()
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            showAlert = true
                        }
                    }) {
                        Text("Save").bold()
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Warning"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        .onAppear {
            updateValidity()
        }
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
        if title.isEmpty {
            isValid = false
            alertMessage = String(localized: "Please fill in the notification title.")
        } else if content.isEmpty {
            isValid = false
            alertMessage = String(localized: "Please fill in the notification text.")
        } else if !isValidTime() {
            isValid = false
            alertMessage = String(localized: "Please select a time in the future.")
        } else {
            isValid = true
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
    @State private var showDeleteAlert = false

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
                if isValid {
                    if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
                        notifications[index] = notification
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification.id.uuidString])
                        scheduleNotification(notification: notification)
                        saveNotifications()
                    }
                    presentationMode.wrappedValue.dismiss()
                } else {
                    showAlert = true
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
                    showDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Warning"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Warning"),
                message: Text("Are you sure you want to delete the scheduled notification\"\(notification.title)\"?\nThis operation cannot be undone"),
                primaryButton: .destructive(Text("Delete")) {
                    if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification.id.uuidString])
                        notifications.remove(at: index)
                    }
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel(Text("Cancel"))
            )
        }
        .onAppear {
            updateValidity()
        }
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
        if notification.title.isEmpty {
            isValid = false
            alertMessage = String(localized: "Please fill in the notification title.")
        } else if notification.content.isEmpty {
            isValid = false
            alertMessage = String(localized: "Please fill in the notification text.")
        } else if !isValidTime() {
            isValid = false
            alertMessage = String(localized: "Please select a time in the future.")
        } else {
            isValid = true
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
    
    var body: some View {
        Form {
            Section(header: Text("Update Log")) {
                Text("Fix the problem that the App icon cannot be changed\nModify icon list text color\nOther minor modifications and bugfixes")
            }
            Section(header: Text("Known Issues")) {
                Text("After modifying the theme, the theme of \"Create Notification\" will not change until the application is restarted")
            }
            Section() {
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

struct LangView: View {
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        Form {
            Section(header: Text("Description")) {
                Text("Please click the button below to jump to the system settings and tap \"Language\" to change your preferred App language.\n\nThe translation may use a large amount of machine translation and contain many errors or irrationalities. If there are any errors in the translation, please go to the feedback form to report it. Thank you!")
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
            Section(header: Text("Description")) {
                Text("Welcome to the Help Center!\nHere you will find information on how to operate this application and more!")
            }
            Section(header: Text("Q: How to schedule notifications?")) {
                Text("Tap the \"+\" symbol in the upper right corner of the home tab, enter the notification title and content, finally set the time and click Save to schedule the notification.")
            }
            Section(header: Text("Q: Any other questions?")) {
                Text("Use our feedback form to get help!")
            }
            Section() {
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
    
    // Description with "AppIcon" removed
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
            Section(header: Text("Choose app icon you want to change")) {
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
