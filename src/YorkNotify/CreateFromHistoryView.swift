//
//  CreateFromHistoryView.swift
//  YorkNotify
//
//  Created by York on 2025/4/25.
//

import Foundation
import SwiftUI
import UserNotifications

struct CreateFromHistoryView: View {
    @Binding var notifications: [NotificationItem]
    @Binding var history: [NotificationItem]

    var sourceNotification: NotificationItem

    @AppStorage("customColor") private var customColorHex: String = ""
    var customColor: Color {
        Color(hex: customColorHex) ?? .blue
    }

    @Environment(\.presentationMode) var presentationMode

    @State private var title: String = ""
    @State private var content: String = ""
    @State private var time: Date = Calendar.current.date(byAdding: .minute, value: 5, to: Date()) ?? Date()
    @State private var repeats: Bool = false
    @State private var repeatFrequency: RepeatFrequency = .daily
    @State private var isValid = false

    var body: some View {
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

            Section {
                Button("Create Notification") {
                    saveNotification()
                }
                .bold()
            }
        }
        .onAppear {
            title = sourceNotification.title
            content = sourceNotification.content
            updateValidity()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .destructive) {
                    deleteHistoryNotification()
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
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
        if let encoded = try? JSONEncoder().encode(notifications) {
            UserDefaults.standard.set(encoded, forKey: "savedNotifications")
        }
    }

    private func scheduleNotification(notification: NotificationItem) {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.content
        content.sound = .default

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
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    private func updateValidity() {
        isValid = !title.isEmpty && !content.isEmpty && time > Date()
    }

    private func deleteHistoryNotification() {
        if let index = history.firstIndex(where: { $0.id == sourceNotification.id }) {
            history.remove(at: index)
            saveHistory()
        }
        presentationMode.wrappedValue.dismiss()
    }

    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: "notificationHistory")
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
