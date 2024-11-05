//
//  PhoneConnectivityManager.swift
//  YorkNotify
//
//  Created by York on 2024/11/3.
//

import Foundation
import WatchConnectivity

class PhoneConnectivityManager: NSObject, ObservableObject {
    static let shared = PhoneConnectivityManager()
    
    private override init() {
        super.init()
        
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func syncNotifications(_ notifications: [NotificationItem]) {
        // Convert NotificationItem to WatchNotificationItem
        let watchNotifications = notifications.map { notification in
            WatchNotificationItem(
                id: notification.id,
                title: notification.title,
                content: notification.content,
                time: notification.time
            )
        }
        
        // Encode and send to watch
        if let encodedData = try? JSONEncoder().encode(watchNotifications) {
            do {
                try WCSession.default.updateApplicationContext([
                    "notifications": encodedData
                ])
            } catch {
                print("Error sending notifications to watch: \(error.localizedDescription)")
            }
        }
    }
}

extension PhoneConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if message["request"] as? String == "notifications" {
            // Trigger a sync when watch requests data
            NotificationCenter.default.post(name: NSNotification.Name("SyncNotificationsToWatch"), object: nil)
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
}
