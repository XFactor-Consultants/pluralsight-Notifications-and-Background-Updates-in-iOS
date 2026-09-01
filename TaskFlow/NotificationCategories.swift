//
//  NotifcationCategoris.swift
//  TaskFlow
//
//  Created by Chris Hewitt on 8/31/26.
//
import UserNotifications
enum NotificationCategories {
    static let taskAssignment = "TASK_ASSIGNMENT"
    
    static func register() {
        let complete = UNNotificationAction(identifier: "COMPLETE_ACTION", title: "Complete", options: [])
        let snooze = UNNotificationAction(identifier: "SNOOZE_ACTION", title: "Snooze", options: [])
        let category = UNNotificationCategory(identifier: taskAssignment, actions: [complete, snooze], intentIdentifiers: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}

