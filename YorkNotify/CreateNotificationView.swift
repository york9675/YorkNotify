//
//  CreateNotificationView.swift
//  YorkNotify
//
//  Created by York on 2024/10/1.
//

import Foundation
import SwiftUI
import UserNotifications

struct CreateNotificationView: View {
    @AppStorage("customColor") private var customColorHex: String = ""

     var customColor: Color {
         Color(hex: customColorHex) ?? .blue
     }
    
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
    
    @AppStorage("enableCustomFrequency") private var enableCustomFrequency = false
    
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
                        if enableCustomFrequency {
                            // Haven't even started making this feature yet
                            Picker("Frequency", selection: $repeatFrequency) {
                                ForEach(RepeatFrequency.allCases) { frequency in
                                    Text(frequency.localizedString).tag(frequency)
                                }
                            }
                        } else {
                            Picker("Frequency", selection: $repeatFrequency) {
                                ForEach(RepeatFrequency.allCases) { frequency in
                                    Text(frequency.localizedString).tag(frequency)
                                }
                            }
                        }
                    }
                    if enableTimeSensitiveNotifications {
                        Toggle("Time Sensitive Notifications", isOn: $isTimeSensitive)
                            .disabled(true)
                    }
                }
            }
            .navigationTitle("Create Notification")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
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
                        Text("Save")
                            .bold()
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

/*
░░░░░██████╗░░██████╗░░░░░
░░░░██╔════╝░██╔════╝░░░░░
░░░░██║░░██╗░██║░░██╗░░░░░
░░░░██║░░╚██╗██║░░╚██╗░░░░
░░░░╚██████╔╝╚██████╔╝░░░░
░░░░░╚═════╝░░╚═════╝░░░░░
*/
