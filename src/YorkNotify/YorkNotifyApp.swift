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
    @StateObject private var appState = AppState()
    
    init() {
        print("Welcome to the YorkNotify app by York!\n\nIf you like this app, please leave a star on the GitHub project page, or consider sponsoring me through Buy Me a Coffee!\nEncounter any problems during use? Please create GitHub Issues or fill out the feedback form to report!")
        print("\n© 2024 York Development")
        print("========== HAVE A NICE DAY! ==========")
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
//                print("Permission granted")
            } else if let error = error {
                print("Error: \(error.localizedDescription)")
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
                .environmentObject(appState)
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
