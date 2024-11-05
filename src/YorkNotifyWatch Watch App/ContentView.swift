//
//  ContentView.swift
//  YorkNotifyWatch Watch App
//
//  Created by York on 2024/10/30.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var connectivityManager = WatchConnectivityManager.shared
    
    @State private var greetingTitle: String = "Notifications"
    
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
        NavigationView {
            VStack {
                if connectivityManager.notifications.isEmpty {
                    VStack {
                        Image(systemName: "bell")
                            .font(.system(size: 40))
                            .padding(.bottom, 8)
                            .foregroundStyle(.secondary)
                        
                        Text("No notifications yet")
                            .font(.headline)
                        
                        Text("Schedule notifications using your iPhone.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    List(connectivityManager.notifications) { notification in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(notification.title)
                                .font(.headline)
                            Text(notification.content)
                                .font(.caption)
                            HStack {
                                Text(notification.time, style: .date)
                                    .font(.caption2)
                                Text("•")
                                    .font(.caption2)
                                Text(notification.time, style: .time)
                                    .font(.caption2)
                            }
                            .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .onAppear {
                updateGreeting()
            }
            .navigationTitle(greetingTitle)
        }
    }
}

#Preview {
    ContentView()
}
