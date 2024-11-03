//
//  PushNotificationService.swift
//  combiningSqlAndSwift
//
//  Created by Alex Kondratiev on 07.10.24.
//

import Foundation
import UserNotifications

struct PushNotificationService {
    
    func requestPermission() {
        let options:UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (success, error) in
            if let error {
                print(error.localizedDescription)
            } else {
                print("Notification permission granted")
            }
        }
    }
    
    func dispatchNotificationWithInterval(identifier: String, title: String, body: String, timeInterval: Double) {
        let identifier = identifier
        let notificationCenter = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notificationCenter.add(request)
        print("Notification was sent successfully")
    }
}
