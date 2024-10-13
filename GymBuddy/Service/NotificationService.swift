//
//  NotificationManager.swift
//  GymBuddy
//
//  Created by Alex Fogg on 12/10/2024.
//


import UserNotifications
import SwiftUI


// class managing notifications
class NotificationService: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()
    
    override private init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    // Request permission from the user to get notifications
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleWorkoutReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Workout Reminder"
        content.body = "Did you have a workout today? It's never too late to track your exercise!"
        content.sound = .default
        
        // Create a trigger for 24 hours from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 24 * 60 * 60, repeats: false)
        
        // Create a unique identifier for the notification
        let identifier = UUID().uuidString
        
        // Create the request
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // Schedule the request
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Workout reminder scheduled successfully")
            }
        }
    }
    
    func cancelAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
