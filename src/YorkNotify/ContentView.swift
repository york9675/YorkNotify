//
//  ContentView.swift
//  YorkNotify
//
//  Created by York on 2024/6/28.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("lastSeenVersion") private var lastSeenVersion: String = ""
    @AppStorage("selectedTheme") private var selectedTheme: String = Theme.system.rawValue
    @AppStorage("customColor") private var customColorHex: String = ""

    @State private var showWhatsNew = false

    var customColor: Color {
        Color(hex: customColorHex) ?? .blue
    }
    
    @EnvironmentObject private var appState: AppState

    var body: some View {
        TabView {
            NotificationListView()
                .tabItem {
                    Label("List", systemImage: "list.bullet")
                }
                .environmentObject(appState)
            
            NotificationHistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
            
            SettingsTabView(selectedTheme: Binding(
                get: { Theme(rawValue: selectedTheme) ?? .system },
                set: { selectedTheme = $0.rawValue }
            ))
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .tint(customColor)
        .preferredColorScheme(Theme(rawValue: selectedTheme)?.colorScheme)
        .sheet(isPresented: $showWhatsNew) {
            WhatsNewSheet()
        }
        .onAppear {
            checkForNewVersion()
        }
    }

    func checkForNewVersion() {
        if lastSeenVersion != whatNewVersion {
            showWhatsNew = true
            lastSeenVersion = whatNewVersion
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
