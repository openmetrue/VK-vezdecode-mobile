//
//  LocalNotification.swift
//  alarm-vk
//
//  Created by Mark Khmelnitskii on 09.07.2022.
//

import Foundation
import UserNotifications
import SwiftUI

class LocalNotification: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published var notificationData: UNNotificationResponse!
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        self.notificationData = response
        completionHandler()
    }
}

class NotificationManager {
    static let shared = NotificationManager()
    
    var notificationPermission: Bool {
        get {
            UserDefaults.standard.bool(forKey: "notificationPermission")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "notificationPermission")
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                self.notificationPermission = true
            } else {
                self.notificationPermission = false
            }
        }
    }
    
    func scheduleRepeatedNotification(id: String, for days: [(String, Bool)], on date: Date) {
        let content = UNMutableNotificationContent()
        content.subtitle = "Будильник"
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "Digital.mp3"))
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        
        let requestIdentifier = id
        let dayToCalendarInt = [
            "ВС": 1,
            "ПH": 2,
            "ВТ": 3,
            "СР": 4,
            "ЧТ": 5,
            "ПТ": 6,
            "СБ": 7
        ]
        for day in days {
            if day.1 {
                var dateComponents = DateComponents()
                dateComponents.hour = hour
                dateComponents.minute = minute
                dateComponents.weekday = dayToCalendarInt[day.0]
                dateComponents.timeZone = .current
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
            }
        }
    }
    
    func cancelScheduledNotification(for id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
}
