//
//  NotificationPermission.swift
//  TaskFlow
//
//  Created by Chris Hewitt on 8/25/26.
//
import UserNotifications
enum NotificationPermission {
    static func requestIfNeeded() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional:
            return true
        case .denied:
            return false
        case .notDetermined:
            let granted = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted ?? false
        default:
            return false
        }
    }
}
