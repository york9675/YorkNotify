//
//  ContentView.swift
//  YorkNotify
//
//  Created by York on 2024/6/28.
//

import SwiftUI
import UserNotifications

let appVersion = "Beta 1.2.4"
let build = "12"

struct ContentView: View {
    @AppStorage("selectedTheme") private var selectedTheme: String = Theme.system.rawValue

    var body: some View {

        TabView {
            HomeTabView()
                .tabItem {
                    Label("首頁", systemImage: "house")
                }
            
            SettingsTabView(selectedTheme: Binding(
                get: { Theme(rawValue: selectedTheme) ?? .system },
                set: { selectedTheme = $0.rawValue }
            ))
                .tabItem {
                    Label("設定", systemImage: "gear")
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
            return String(localized: "系統")
        case .light:
            return String(localized: "淺色")
        case .dark:
            return String(localized: "深色")
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
    @State private var greetingTitle: String = "首頁"
    @State private var showSettingsAlert = false
    
    enum SortOrder: String, CaseIterable, Identifiable {
        case time = "照通知時間排序"
        case alphabetical = "照A-Z排序"

        var id: String { self.rawValue }
    }
    
    private func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
            case 5..<12:
                greetingTitle = String(localized: "早安")
            case 12..<18:
                greetingTitle = String(localized: "午安")
            default:
                greetingTitle = String(localized: "晚安")
        }
    }
    
    private func checkNotificationSettings() {
        let current = UNUserNotificationCenter.current()
        current.getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .denied {
                    print("沒權限傳通知！")
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
                        Text("暫無通知")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("點擊右上方「+」來排程通知。")
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
                                    Label("刪除", systemImage: "trash")
                                }
                                .tint(.red)
                            }
                            .alert(isPresented: $showDeleteAlert) {
                                Alert(
                                    title: Text("警告"),
                                    message: Text("您確定刪除已排程的通知「\(notificationToDelete?.title ?? "")」？\n此操作無法復原"),
                                    primaryButton: .destructive(Text("刪除")) {
                                        if let notification = notificationToDelete,
                                           let index = notifications.firstIndex(where: { $0.id == notification.id }) {
                                            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification.id.uuidString])
                                            notifications.remove(at: index)
                                        }
                                    },
                                    secondaryButton: .cancel(Text("取消"))
                                )
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "搜尋通知")
            .onAppear {
                loadNotifications()
                updateGreeting()
                checkNotificationSettings()
            }
            .navigationTitle(greetingTitle)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Section("更改排序方式") {
                            Button(action: {
                                sortOrder = .time
                            }) {
                                Label("照通知時間", systemImage: "clock")
                            }
                            
                            Button(action: {
                                sortOrder = .alphabetical
                            }) {
                                Label("照A-Z", systemImage: "character")
                            }
                        }
                    } label: {
                        Label("排序方式", systemImage: "ellipsis.circle")
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showingCreateView = true
                    }) {
                        Label("創建通知", systemImage: "plus")
                    }
                    .sheet(isPresented: $showingCreateView) {
                        CreateNotificationView(notifications: $notifications)
                    }
                }
                
            }
            .alert(isPresented: $showSettingsAlert) {
                Alert(
                    title: Text("通知權限未開啟"),
                    message: Text("請至系統設定允許通知，否則程式將無法如期運作。\n（放心，我們不會寄送垃圾通知！）"),
                    dismissButton: .default(Text("前往設定")) {
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
            return String(localized: "每日")
        case .weekly:
            return String(localized: "每週")
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
                Section(header: Text("通知內容")) {
                    TextField("通知標題", text: $title)
                        .onChange(of: title) { _ in updateValidity() }
                    TextField("通知內文", text: $content)
                        .onChange(of: content) { _ in updateValidity() }
                }
                Section(header: Text("通知設定")) {
                    DatePicker("時間", selection: $time, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                        .onChange(of: time) { _ in updateValidity() }
                    Toggle("重複", isOn: $repeats)
                    if repeats {
                        Picker("重複頻率", selection: $repeatFrequency) {
                            ForEach(RepeatFrequency.allCases) { frequency in
                                Text(frequency.localizedString).tag(frequency)
                            }
                        }
                    }
                }
            }
            .navigationTitle("創建通知")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
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
                        Text("儲存").bold()
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("警告"), message: Text(alertMessage), dismissButton: .default(Text("確定")))
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
            alertMessage = String(localized: "請填寫通知標題")
        } else if content.isEmpty {
            isValid = false
            alertMessage = String(localized: "請填寫通知內容")
        } else if !isValidTime() {
            isValid = false
            alertMessage = String(localized: "請選擇未來的時間")
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
                print("通知設定失敗 \(error.localizedDescription)")
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
            Section(header: Text("通知內容")) {
                TextField("通知標題", text: $notification.title)
                    .onChange(of: notification.title) { _ in updateValidity() }
                TextField("通知內文", text: $notification.content)
                    .onChange(of: notification.content) { _ in updateValidity() }
            }
            Section(header: Text("通知設定")) {
                DatePicker("時間", selection: $notification.time, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                    .onChange(of: notification.time) { _ in updateValidity() }
                Toggle("重複", isOn: $notification.repeats)
                if notification.repeats {
                    Picker("重複頻率", selection: $notification.repeatFrequency) {
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
                Text("儲存").bold()
            }
        }
        .navigationTitle("編輯通知")
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
            Alert(title: Text("警告"), message: Text(alertMessage), dismissButton: .default(Text("確定")))
        }
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("警告"),
                message: Text("您確定刪除已排程的通知「\(notification.title)」？\n此操作無法復原"),
                primaryButton: .destructive(Text("刪除")) {
                    if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification.id.uuidString])
                        notifications.remove(at: index)
                    }
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel(Text("取消"))
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
            alertMessage = String(localized: "請填寫通知標題")
        } else if notification.content.isEmpty {
            isValid = false
            alertMessage = String(localized: "請填寫通知內容")
        } else if !isValidTime() {
            isValid = false
            alertMessage = String(localized: "請選擇未來的時間")
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
                print("通知設定失敗 \(error.localizedDescription)")
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
                
                Section(header: Text("一般")) {
                    Picker(selection: $selectedTheme, label: Label("主題", systemImage: "moon")) {
                        ForEach(Theme.allCases) { theme in
                            Text(theme.localizedString).tag(theme)
                        }
                    }
                    
                    NavigationLink(destination: IconView()) {
                        HStack {
                            Label("App圖標", systemImage: "square.grid.2x2")
                        }
                    }
                    
                    NavigationLink(destination: LangView()) {
                        HStack {
                            Label("語言", systemImage: "globe")
                        }
                    }
                }
                
                Section(header: Text("關於"), footer: Text("2024 York Development")) {
                    NavigationLink(destination: HelpView()) {
                        HStack {
                            Label("幫助", systemImage: "questionmark.circle")
                        }
                    }
                    
                    NavigationLink(destination: AutherView()) {
                        HStack {
                            Label("作者", systemImage: "person")
                            Spacer()
                            Text("York")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    NavigationLink(destination: VersionView()) {
                        HStack {
                            Label("版本", systemImage: "info.circle")
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
                            Label("意見回饋", systemImage: "info.bubble")
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
//                                Text("警告")
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
//                        Text("測試版可能包含許多bug")
//                            .font(.footnote)
//                        
//                    }
//                    .padding(.vertical, 5)
//                }
                
            }
            .navigationTitle("設定")
        }
    }
}

struct VersionView: View {
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        Form {
            Section(header: Text("更新日誌")) {
                Text("修復App icon無法更換的問題\n修改icon列表文字顏色")
            }
            Section(header: Text("已知問題")) {
                Text("修改主題後創建通知的主題在重新啟動應用程式前不會改變")
            }
            Section() {
                Button(action: {
                    if let url = URL(string: "https://forms.gle/o1hFjy4q98Ua1H7L7") {
                        openURL(url)
                    }
                }) {
                    HStack {
                        Label("問題回報", systemImage: "exclamationmark.triangle")
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
            Text("請點擊下方按鈕跳進入系統設定，並點選「語言」來更改您偏好的App語言。\n\n翻譯可能使用大量機器翻譯，並包含許多錯誤或不合理之處，如翻譯有誤，請前往意見回饋表單回報，感謝！")
            Button(action: {
                let url = URL(string: UIApplication.openSettingsURLString)!
                            UIApplication.shared.open(url)
            }) {
                HStack {
                    Label("App設定", systemImage: "gear")
                }
            }
            Button(action: {
                if let url = URL(string: "https://forms.gle/o1hFjy4q98Ua1H7L7") {
                    openURL(url)
                }
            }) {
                HStack {
                    Label("翻譯問題回報", systemImage: "exclamationmark.triangle")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("更換語言")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct HelpView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        Form{
            Section(header: Text("說明")) {
                Text("歡迎來到幫助中心！\n這裡會提供關於操作本應用程式的方法等！")
            }
            Section(header: Text("Q: 如何排程通知？")) {
                Text("點擊首頁右上方「+」的符號，輸入通知標題及內文，最後設定好時間並且按下保存後即可排程通知。")
            }
            Section(header: Text("Q: 還有其他問題？")) {
                Text("使用我們的問題回報表單尋求協助！")
            }
            Section() {
                Button(action: {
                    if let url = URL(string: "https://forms.gle/o1hFjy4q98Ua1H7L7") {
                        openURL(url)
                    }
                }) {
                    HStack {
                        Label("問題回報", systemImage: "exclamationmark.triangle")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .navigationTitle("幫助中心")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AutherView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        Form {
            Text("此應用程式的開發者！")
            Section(header: Text("連結")) {
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
            Section(header: Text("贊助")) {
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
            Section(header: Text("選擇要更換的App圖標")) {
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
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        .navigationTitle("App圖標")
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
                    print("Error domain: \(error._domain)")
                    print("Error code: \(error._code)")
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
