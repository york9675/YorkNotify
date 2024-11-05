//
//  EditNotificationView.swift
//  YorkNotify
//
//  Created by York on 2024/10/1.
//

import Foundation
import SwiftUI
import UserNotifications

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

    @AppStorage("defaultNotificationTitle") private var defaultTitle: String = "YorkNotify"
    @AppStorage("defaultNotificationContent") private var defaultContent: String = "Please remember."
    @AppStorage("showMissingInfoAlert") private var showMissingInfoAlert = true

    @State private var isTimeSensitive = false
    @AppStorage("enableTimeSensitiveNotifications") private var enableTimeSensitiveNotifications = false

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
                    .tint(.green)
                
                if notification.repeats {
                    Picker("Frequency", selection: $notification.repeatFrequency) {
                        ForEach(RepeatFrequency.allCases) { frequency in
                            Text(frequency.localizedString).tag(frequency)
                        }
                    }
                }
                if enableTimeSensitiveNotifications {
                    Toggle("Time Sensitive Notifications", isOn: $isTimeSensitive)
                        .tint(.green)
                        .disabled(true)
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
                Text("Save")
                    .bold()
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
                print("Error: \(error.localizedDescription)")
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
