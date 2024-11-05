//
//  WatchConnectivityManager.swift
//  YorkNotifyWatch Watch App
//
//  Created by York on 2024/11/3.
//

import Foundation
import WatchConnectivity

class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    @Published var notifications: [WatchNotificationItem] = []
    
    private override init() {
        super.init()
        
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Request initial data after activation
        if activationState == .activated {
            session.sendMessage(["request": "notifications"], replyHandler: nil) { error in
                print("Error requesting notifications: \(error.localizedDescription)")
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
            if let notificationData = applicationContext["notifications"] as? Data {
                if let decodedNotifications = try? JSONDecoder().decode([WatchNotificationItem].self, from: notificationData) {
                    self.notifications = decodedNotifications
                }
            }
        }
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
    #endif
}
