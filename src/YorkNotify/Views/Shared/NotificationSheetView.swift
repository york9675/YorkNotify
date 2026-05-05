//
//  NotificationSheetView.swift
//  YorkNotify
//
//  Created by York on 2026/4/28.
//

import Foundation
import SwiftUI
import UserNotifications

struct NotificationSheetView: View {
    enum Mode {
        case create
        case edit
        case history
    }

    @AppStorage("customColor") private var customColorHex: String = ""

    var customColor: Color {
        Color(hex: customColorHex) ?? .blue
    }

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    @Binding var notifications: [NotificationItem]
    @Binding private var history: [NotificationItem]

    private let mode: Mode
    private let originalNotification: NotificationItem?
    private let sourceHistoryNotification: NotificationItem?
    private let comparisonNotification: NotificationItem?

    @State private var title = ""
    @State private var content = ""
    @State private var time = Calendar.current.date(byAdding: .minute, value: 5, to: Date()) ?? Date()
    @State private var repeats = false
    @State private var repeatFrequency: RepeatFrequency = .daily
    @State private var customRepeatValue = 1
    @State private var customRepeatUnit: RepeatCustomUnit = .day
    @State private var repeatEndCondition: RepeatEndCondition = .never
    @State private var repeatEndDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    @State private var minimumSelectableTime = Date()
    @State private var isValid = false
    @State private var isTimeSensitive = false

    @State private var alertMessage = ""

    enum ActiveAlert: Identifiable {
        case delete, deleteHistory, warning, proceedWithDefault, discardChanges

        var id: String {
            switch self {
            case .delete: return "delete"
            case .deleteHistory: return "deleteHistory"
            case .warning: return "warning"
            case .proceedWithDefault: return "proceedWithDefault"
            case .discardChanges: return "discardChanges"
            }
        }
    }

    @State private var activeAlert: ActiveAlert? = nil

    @AppStorage("defaultNotificationTitle") private var defaultTitle: String = "York Notify"
    @AppStorage("defaultNotificationContent") private var defaultContent: String = "Please remember."
    @AppStorage("showMissingInfoAlert") private var showMissingInfoAlert = true
    @AppStorage("enableTimeSensitiveNotifications") private var enableTimeSensitiveNotifications = false

    private var minimumRepeatEndDate: Date {
        Calendar.current.startOfDay(for: time)
    }

    private var repeatEndDateBinding: Binding<Date> {
        Binding<Date>(
            get: { repeatEndDate },
            set: { repeatEndDate = $0 }
        )
    }

    private var isEditMode: Bool {
        mode == .edit
    }

    private var isHistoryMode: Bool {
        mode == .history
    }

    private var hasChanges: Bool {
        guard let original = comparisonNotification else {
            return !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                   !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

         return title != original.title ||
             content != original.content ||
             normalizedTime(time) != normalizedTime(original.time) ||
               repeats != original.repeats ||
               repeatFrequency != original.repeatFrequency ||
               customRepeatValue != original.customRepeatValue ||
               customRepeatUnit != original.customRepeatUnit ||
               repeatEndCondition != original.repeatEndCondition ||
               currentEffectiveRepeatEndDate != originalEffectiveRepeatEndDate
    }

    private var isTimeChanged: Bool {
        guard let original = originalNotification else { return false }
        return normalizedTime(time) != normalizedTime(original.time)
    }

    init(notifications: Binding<[NotificationItem]>) {
        _notifications = notifications
        _history = .constant([])
        mode = .create
        originalNotification = nil
        sourceHistoryNotification = nil
        comparisonNotification = nil
        _minimumSelectableTime = State(initialValue: Date())
    }

    init(notification: NotificationItem, notifications: Binding<[NotificationItem]>) {
        _notifications = notifications
        _history = .constant([])
        mode = .edit
        originalNotification = notification
        sourceHistoryNotification = nil
        comparisonNotification = notification
        _minimumSelectableTime = State(initialValue: Date())

        _title = State(initialValue: notification.title)
        _content = State(initialValue: notification.content)
        _time = State(initialValue: notification.time)
        _repeats = State(initialValue: notification.repeats)
        _repeatFrequency = State(initialValue: notification.repeatFrequency)
        _customRepeatValue = State(initialValue: notification.customRepeatValue)
        _customRepeatUnit = State(initialValue: notification.customRepeatUnit)
        _repeatEndCondition = State(initialValue: notification.repeatEndCondition)
        _repeatEndDate = State(initialValue: notification.repeatEndDate ?? Calendar.current.date(byAdding: .day, value: 1, to: notification.time) ?? Date())
        _isTimeSensitive = State(initialValue: false)
    }

    init(sourceNotification: NotificationItem, notifications: Binding<[NotificationItem]>, history: Binding<[NotificationItem]>) {
        _notifications = notifications
        _history = history
        mode = .history
        originalNotification = nil
        sourceHistoryNotification = sourceNotification
        let initialTime = Calendar.current.date(byAdding: .minute, value: 5, to: Date()) ?? Date()
        _minimumSelectableTime = State(initialValue: Date())
        comparisonNotification = NotificationItem(
            title: sourceNotification.title,
            content: sourceNotification.content,
            time: initialTime,
            repeats: sourceNotification.repeats,
            repeatFrequency: sourceNotification.repeatFrequency,
            customRepeatValue: sourceNotification.customRepeatValue,
            customRepeatUnit: sourceNotification.customRepeatUnit,
            repeatEndCondition: sourceNotification.repeatEndCondition,
            repeatEndDate: sourceNotification.repeatEndDate
        )

        _title = State(initialValue: sourceNotification.title)
        _content = State(initialValue: sourceNotification.content)
        _repeats = State(initialValue: sourceNotification.repeats)
        _repeatFrequency = State(initialValue: sourceNotification.repeatFrequency)
        _customRepeatValue = State(initialValue: sourceNotification.customRepeatValue)
        _customRepeatUnit = State(initialValue: sourceNotification.customRepeatUnit)
        _repeatEndCondition = State(initialValue: sourceNotification.repeatEndCondition)
        _repeatEndDate = State(initialValue: sourceNotification.repeatEndDate ?? Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date())
        _isTimeSensitive = State(initialValue: false)
        _time = State(initialValue: initialTime)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Notification Content")) {
                    TextField("Notification Title", text: $title)
                        .onChange(of: title) { _ in updateValidity() }

                    TextField("Notification Text", text: $content)
                        .onChange(of: content) { _ in updateValidity() }
                }
                Section(header: Text("Notification Settings")) {
                    if isEditMode {
                        DatePicker("Time", selection: $time, displayedComponents: [.date, .hourAndMinute])
                            .onChange(of: time) { _ in updateValidity() }
                    } else {
                        DatePicker("Time", selection: $time, in: minimumSelectableTime..., displayedComponents: [.date, .hourAndMinute])
                            .onChange(of: time) { _ in updateValidity() }
                    }

                    Toggle("Repeat", isOn: $repeats)
                        .tint(.green)
                        .onChange(of: repeats) { newValue in
                            if !newValue {
                                repeatEndCondition = .never
                                repeatEndDate = Calendar.current.date(byAdding: .day, value: 1, to: time) ?? Date()
                            }
                            updateValidity()
                        }

                    if repeats {
                        Picker("Frequency", selection: $repeatFrequency) {
                            ForEach(RepeatFrequency.allCases.filter { $0 != .custom }) { frequency in
                                Text(frequency.localizedString).tag(frequency)
                            }

                            Divider()

                            Text(RepeatFrequency.custom.localizedString)
                                .tag(RepeatFrequency.custom)
                        }
                        .onChange(of: repeatFrequency) { _ in
                            updateValidity()
                        }

                        if repeatFrequency == .custom {
                            Stepper(value: $customRepeatValue, in: 1...365) {
                                Text("Every: \(customRepeatValue)")
                            }

                            Picker("Unit", selection: $customRepeatUnit) {
                                ForEach(RepeatCustomUnit.allCases) { unit in
                                    Text(unit.localizedString).tag(unit)
                                }
                            }
                        }

                        Picker("Stop Repeating", selection: $repeatEndCondition) {
                            ForEach(RepeatEndCondition.allCases) { condition in
                                Text(condition.localizedString).tag(condition)
                            }
                        }
                        .onChange(of: repeatEndCondition) { _ in
                            if repeatEndCondition == .onDate && repeatEndDate < minimumRepeatEndDate {
                                repeatEndDate = minimumRepeatEndDate
                            }
                            updateValidity()
                        }

                        if repeatEndCondition == .onDate {
                            DatePicker(
                                "End Date",
                                selection: repeatEndDateBinding,
                                in: minimumRepeatEndDate...,
                                displayedComponents: .date
                            )
                            .onChange(of: repeatEndDate) { _ in
                                updateValidity()
                            }
                        }
                    }
                    if enableTimeSensitiveNotifications {
                        Toggle("Time Sensitive Notifications", isOn: $isTimeSensitive)
                            .tint(.green)
                            .disabled(true)
                    }
                }

                if isEditMode {
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

                if isHistoryMode {
                    Button(action: {
                        if title.isEmpty || content.isEmpty {
                            handleMissingInfo()
                        } else if isValid {
                            saveNotification()
                        } else {
                            activeAlert = .warning
                        }
                    }) {
                        Text("Create Notification")
                            .bold()
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Group {
                        if #available(iOS 26.0, *) {
                            Button(action: {
                                attemptDismiss()
                            }) {
                                Image(systemName: "xmark")
                                    .foregroundStyle(.primary)
                            }
                            .tint(.primary)
                            .accessibilityLabel("Cancel")
                        } else {
                            Button(action: {
                                attemptDismiss()
                            }) {
                                Text("Cancel")
                            }
                            .accessibilityLabel("Cancel")
                        }
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    switch mode {
                    case .edit:
                        Button(action: {
                            activeAlert = .delete
                        }) {
                            if #available(iOS 26.0, *) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            } else {
                                Text("Delete")
                                    .foregroundColor(.red)
                                    .bold()
                            }
                        }
                    case .history:
                        Button(role: .destructive) {
                            activeAlert = .deleteHistory
                        } label: {
                            if #available(iOS 26.0, *) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            } else {
                                Text("Delete")
                                    .foregroundColor(.red)
                                    .bold()
                            }
                        }
                    case .create:
                        Button(action: {
                            if title.isEmpty || content.isEmpty {
                                handleMissingInfo()
                            } else if isValid {
                                saveNotification()
                            } else {
                                activeAlert = .warning
                            }
                        }) {
                            if #available(iOS 26.0, *) {
                                Image(systemName: "checkmark")
                                    .opacity(0)
                            } else {
                                Text("Save")
                                    .bold()
                            }
                        }
                        .liquidGlassProminentButtonIfAvailable()
                        .overlay {
                            if #available(iOS 26.0, *) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.white)
                            }
                        }
                        .accessibilityLabel("Save")
                    }
                }
            }
            .alert(item: $activeAlert) { alertType in
                switch alertType {
                case .delete:
                    return Alert(
                        title: Text("Warning"),
                        message: Text("Are you sure you want to delete the scheduled notification \"\(title)\"?\nThis operation cannot be undone"),
                        primaryButton: .destructive(Text("Delete")) {
                            if let original = originalNotification,
                               let index = notifications.firstIndex(where: { $0.id == original.id }) {
                                NotificationScheduler.removePendingRequests(for: original.id)
                                notifications.remove(at: index)
                                saveNotifications()
                            }
                            dismiss()
                        },
                        secondaryButton: .cancel(Text("Cancel"))
                    )

                case .deleteHistory:
                    return Alert(
                        title: Text("Delete Notification?"),
                        message: Text("This will remove this item from your history."),
                        primaryButton: .destructive(Text("Delete")) {
                            deleteHistoryNotification()
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

                case .discardChanges:
                    return Alert(
                        title: Text("Discard Changes?"),
                        message: Text("You have unsaved changes. Are you sure you want to close this sheet?"),
                        primaryButton: .destructive(Text("Discard")) {
                            if isEditMode {
                                dismiss()
                            } else {
                                presentationMode.wrappedValue.dismiss()
                            }
                        },
                        secondaryButton: .cancel(Text("Cancel"))
                    )
                }
            }
        }
        .interactiveDismissDisabled(hasChanges)
        .onAppear {
            updateValidity()
        }
    }

    private var navigationTitle: String {
        switch mode {
        case .create:
            String(localized: "Create Notification")
        case .edit:
            String(localized: "Edit Notification")
        case .history:
            String(localized: "Create From History")
        }
    }

    private func saveNotification() {
        switch mode {
        case .edit:
            if let original = originalNotification,
               let index = notifications.firstIndex(where: { $0.id == original.id }) {
                let endDate: Date? = repeats && repeatEndCondition == .onDate ? repeatEndDate : nil

                notifications[index] = NotificationItem(
                    id: original.id,
                    title: title,
                    content: content,
                    time: time,
                    repeats: repeats,
                    repeatFrequency: repeatFrequency,
                    customRepeatValue: customRepeatValue,
                    customRepeatUnit: customRepeatUnit,
                    repeatEndCondition: repeatEndCondition,
                    repeatEndDate: endDate
                )

                NotificationScheduler.removePendingRequests(for: original.id) {
                    NotificationScheduler.schedule(notifications[index], isTimeSensitive: isTimeSensitive)
                }
                saveNotifications()
            }
            dismiss()
        case .create, .history:
            let endDate: Date? = repeats && repeatEndCondition == .onDate ? repeatEndDate : nil

            let newNotification = NotificationItem(
                title: title,
                content: content,
                time: time,
                repeats: repeats,
                repeatFrequency: repeatFrequency,
                customRepeatValue: customRepeatValue,
                customRepeatUnit: customRepeatUnit,
                repeatEndCondition: repeatEndCondition,
                repeatEndDate: endDate
            )
            notifications.append(newNotification)
            if mode == .history {
                NotificationScheduler.schedule(newNotification)
            } else {
                NotificationScheduler.schedule(newNotification, isTimeSensitive: isTimeSensitive)
            }
            saveNotifications()
            presentationMode.wrappedValue.dismiss()
        }
    }

    private func saveNotifications() {
        if let encodedData = try? JSONEncoder().encode(notifications) {
            UserDefaults.standard.set(encodedData, forKey: "savedNotifications")
        }
    }

    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: "notificationHistory")
        }
    }

    private func deleteHistoryNotification() {
        guard let source = sourceHistoryNotification else {
            return
        }

        if let index = history.firstIndex(where: { $0.id == source.id }) {
            history.remove(at: index)
            saveHistory()
        }
        presentationMode.wrappedValue.dismiss()
    }

    private func isValidTime() -> Bool {
        if isEditMode {
            return !isTimeChanged || time > Date()
        } else {
            return time > Date()
        }
    }

    private func updateValidity() {
        if title.isEmpty || content.isEmpty {
            isValid = false
            alertMessage = "Please fill in the notification title and text."
        } else if !isValidTime() {
            isValid = false
            alertMessage = isEditMode ? "Please select a future time when changing the original time." : "Please select a time in the future."
        } else if repeats && repeatEndCondition == .onDate {
            let startDay = Calendar.current.startOfDay(for: time)
            let endDay = Calendar.current.startOfDay(for: repeatEndDate)

            if endDay < startDay {
                isValid = false
                alertMessage = "Please choose an end date after the start date."
                return
            }

            isValid = true
        } else {
            isValid = true
        }
    }

    private func normalizedTime(_ date: Date) -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        return Calendar.current.date(from: components) ?? date
    }

    private var currentEffectiveRepeatEndDate: Date? {
        repeatEndCondition == .onDate ? repeatEndDate : nil
    }

    private var originalEffectiveRepeatEndDate: Date? {
        guard let original = comparisonNotification else { return nil }
        return original.repeatEndCondition == .onDate ? original.repeatEndDate : nil
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

    private func attemptDismiss() {
        if hasChanges {
            activeAlert = .discardChanges
        } else {
            if isEditMode {
                dismiss()
            } else {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

#Preview {
    NotificationSheetPreviewContainer()
}

private struct NotificationSheetPreviewContainer: View {
    @State private var notifications: [NotificationItem] = [NotificationItem.previewSample]

    var body: some View {
        NavigationStack {
            NotificationSheetView(notifications: $notifications)
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
