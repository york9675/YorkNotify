//
//  NotificationHistoryView.swift
//  YorkNotify
//
//  Created by York on 2025/4/23.
//

import Foundation
import SwiftUI

struct NotificationHistoryView: View {
    @State private var history: [NotificationItem] = []
    @State private var sortOrder: SortOrder = .time
    @State private var searchText: String = ""
    @State private var pendingDeleteItem: NotificationItem?
    @State private var showDeleteConfirmation = false
    @State private var selectedHistoryItem: NotificationItem?
    @AppStorage("groupByDate") private var groupByDate: Bool = true
    
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
    
    @ViewBuilder
    private func notificationRow(for item: NotificationItem) -> some View {
        Button(action: {
            selectedHistoryItem = item
        }) {
            VStack(alignment: .leading) {
                Text(item.title)
                    .font(.headline)
                Text(item.content)
                    .font(.body)
                Text(groupByDate ? item.time.formatted(date: .omitted, time: .shortened)
                                 : item.time.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                pendingDeleteItem = item
                showDeleteConfirmation = true
            } label: {
                Label("Delete", systemImage: "trash")
                    .tint(.red)
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                if searchResults.isEmpty {
                    VStack {
                        Image(systemName: "tray")
                            .padding(.bottom, 5)
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No notification history yet")
                            .font(.headline)
                        Text("Sent notifications will appear here.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    List {
                        if groupByDate {
                            ForEach(groupedHistory, id: \.0) { date, items in
                                Section(header: Text(formatSectionHeader(date))) {
                                    ForEach(items) { item in
                                        notificationRow(for: item)
                                    }
                                }
                            }
                        } else {
                            ForEach(searchResults) { item in
                                notificationRow(for: item)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker(selection: $sortOrder, label: Text("Sort by...")) {
                            ForEach(SortOrder.allCases) { sort in
                                Label(sort.localizedString, systemImage: sort == .time ? "clock" : "character")
                                    .tag(sort)
                            }
                        }
                        .tint(.primary)
                        
                        Divider()
                        
                        Toggle(isOn: $groupByDate) {
                                Label("Group by Date", systemImage: "calendar")
                        }
                        .tint(.primary)

                    } label: {
                        Label("Sort by...", systemImage: "arrow.up.arrow.down")
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search History")
            .sheet(item: $selectedHistoryItem) { item in
                NotificationSheetView(
                    sourceNotification: item,
                    notifications: $history,
                    history: $history
                )
            }
            .alert("Delete Notification?", isPresented: $showDeleteConfirmation, presenting: pendingDeleteItem) { item in
                Button("Delete", role: .destructive) {
                    delete(item)
                    pendingDeleteItem = nil
                }
                Button("Cancel", role: .cancel) {
                    pendingDeleteItem = nil
                }
            } message: { item in
                Text("This will remove \"\(item.title)\" from your history.")
            }
            .onAppear {
                loadHistory()
            }
        }
    }

    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: "notificationHistory"),
           let decoded = try? JSONDecoder().decode([NotificationItem].self, from: data) {
            self.history = decoded
        }
    }

    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: "notificationHistory")
        }
    }

    private func delete(_ item: NotificationItem) {
        if let index = history.firstIndex(where: { $0.id == item.id }) {
            history.remove(at: index)
            saveHistory()
        }
    }

    private var sortedHistory: [NotificationItem] {
        switch sortOrder {
        case .time:
            return history.sorted { $0.time > $1.time }
        case .alphabetical:
            return history.sorted { $0.title < $1.title }
        }
    }

    private var searchResults: [NotificationItem] {
        if searchText.isEmpty {
            return sortedHistory
        } else {
            return sortedHistory.filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.content.localizedCaseInsensitiveContains(searchText) }
        }
    }

    private var groupedHistory: [(Date, [NotificationItem])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: searchResults) { notification in
            calendar.startOfDay(for: notification.time)
        }
        return grouped.sorted { $0.key > $1.key }
    }

    private func formatSectionHeader(_ date: Date) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        let includeYear = !calendar.isDate(date, equalTo: Date(), toGranularity: .year)
        let template = includeYear ? "EEE, MMM d, yyyy" : "EEE, MMM d"
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: template, options: 0, locale: Locale.current)
        return formatter.string(from: date)
    }
}

#Preview {
    NotificationHistoryView()
}

/*
░░░░░██████╗░░██████╗░░░░░
░░░░██╔════╝░██╔════╝░░░░░
░░░░██║░░██╗░██║░░██╗░░░░░
░░░░██║░░╚██╗██║░░╚██╗░░░░
░░░░╚██████╔╝╚██████╔╝░░░░
░░░░░╚═════╝░░╚═════╝░░░░░
*/
