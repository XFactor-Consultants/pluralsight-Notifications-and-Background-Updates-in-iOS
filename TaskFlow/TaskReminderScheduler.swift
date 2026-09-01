//
//  TaskReminderScheduler.swift
//  TaskFlow
//
//  Created by Chris Hewitt on 8/25/26.
//

import UserNotifications
enum TaskReminderScheduler {
    
    static func scheduleDueReminder(for task: TaskItem) {
        
        guard let dueDate = task.dueDate else { return }
        
        let content = UNMutableNotificationContent()
        
        content.title = task.title
        content.body = "This task is due."

        
        content.sound = task.priority == .high ? .defaultCritical : .default
        content.badge = 1
        content.categoryIdentifier = NotificationCategories.taskAssignment

        
        let trigger = UNCalendarNotificationTrigger(
            
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate),
            
            repeats: false
        )
        
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        
    }
}
