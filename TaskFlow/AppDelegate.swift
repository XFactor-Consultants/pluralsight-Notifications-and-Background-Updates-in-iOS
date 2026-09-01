//
//  AppDelegate.swift
//  TaskFlow
//
//  Created by Chris Hewitt on 8/31/26.
//

import UIKit

enum RemoteNotificationRegistrar {
    
    static func send(_ token: String) async {
        
        try? await Task.sleep(for: .seconds(1))
        
        print("Sent device token to backend: \(token)")
        
    }
    
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        application.registerForRemoteNotifications()
        
        return true
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let token = deviceToken.map { String(format: "%02x", $0) }.joined()
        
        Task {
            
            await RemoteNotificationRegistrar.send(token)
            
        }
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print("Remote registration failed: \(error)")
        
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult {
        guard let payload = TaskAssignmentPayload(userInfo: userInfo) else {
            print("Malformed remote payload — ignoring.")
            return .noData
        }
        print("Processed remote assignment: \(payload.title) for \(payload.assigneeName)")
        // In a real app, this would reach into the shared TasksStore via
        // dependency injection rather than a global — simplified here.
        return .newData
    }
}

