//
//  YorkNotifyApp.swift
//  YorkNotify
//
//  Created by York on 2024/6/28.
//

import SwiftUI
import UserNotifications

@main
struct YorkNotifyApp: App {
    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else {
                print("Notification permission denied.")
            }
        }

        UIApplication.shared.applicationIconBadgeNumber = 0

        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
