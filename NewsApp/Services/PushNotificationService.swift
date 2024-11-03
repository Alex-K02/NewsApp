//
//  PushNotificationService.swift
//  combiningSqlAndSwift
//
//  Created by Alex Kondratiev on 07.10.24.
//

import Foundation
import UserNotifications

struct NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    /// Request notification permission from the user
    func requestPermission(completion: ((Bool) -> Void)? = nil) {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
                completion?(false)
            } else {
                print("Notification permission granted")
                completion?(true)
            }
        }
    }
    
    /// Dispatch a notification with a specified time interval
    func dispatchNotification(
        identifier: String,
        title: String,
        body: String,
        timeInterval: TimeInterval
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, timeInterval), repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error adding notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully")
            }
        }
    }
}
