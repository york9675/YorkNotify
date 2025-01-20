//
//  ContentView.swift
//  YorkNotifyWatch Watch App
//
//  Created by York on 2025/1/20.
//

import SwiftUI

struct ContentView: View {
    @State private var greetingTitle: String = "Home"

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

    var body: some View {
        NavigationStack {
            List {
                NavigationLink(destination: NotificationListView()) {
                    Label("Notification List", systemImage: "list.bullet")
                }
                NavigationLink(destination: SettingsView()) {
                    Label("Settings", systemImage: "gear")
                }
            }
            .onAppear {
                updateGreeting()
            }
            .navigationTitle(greetingTitle)
        }
    }
}
