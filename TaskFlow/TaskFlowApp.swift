import SwiftUI
import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    var tasksStore: TasksStore?
    var navigationState: NotificationNavigationState?

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        []
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        print("didReceive fired — action: \(response.actionIdentifier)")
        switch response.actionIdentifier {
        case "COMPLETE_ACTION":
            if let payload = TaskAssignmentPayload(userInfo: response.notification.request.content.userInfo) {
                await MainActor.run {
                    if let task = tasksStore?.task(id: payload.taskID) {
                        tasksStore?.toggleComplete(task)
                    }
                }
            }
        case "SNOOZE_ACTION":
            print("Snooze tapped — reschedule goes here.")
        default:
            if let payload = TaskAssignmentPayload(userInfo: response.notification.request.content.userInfo) {
                navigationState?.pendingTaskID = payload.taskID
            }
        }
    }
}

@main
struct TaskFlowApp: App {
    @State private var tasksStore = TasksStore()
    @State private var notificationDelegate = NotificationDelegate()
    @State private var navigationState = NotificationNavigationState()
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(tasksStore)
                .environment(navigationState)
                .onAppear {
                    UNUserNotificationCenter.current().delegate = notificationDelegate
                    NotificationCategories.register()
                    notificationDelegate.tasksStore = tasksStore
                    notificationDelegate.navigationState = navigationState
                }
        }
    }
}
