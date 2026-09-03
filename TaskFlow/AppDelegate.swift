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
    var backgroundSessionCompletionHandler: (() -> Void)?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        application.registerForRemoteNotifications()
        BackgroundRefreshScheduler.register()
        BackgroundRefreshScheduler.schedule()
        BackgroundArchiveScheduler.register()
        BackgroundArchiveScheduler.schedule()
        
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
        print("didReceiveRemoteNotification FIRED")
        await RefreshCoordinator.refresh()
        guard let payload = TaskAssignmentPayload(userInfo: userInfo) else {
            return .noData
        }
        return .newData
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        
        backgroundSessionCompletionHandler = completionHandler
        print("Background URLSession finished: (identifier)")
    }
    #if DEBUG
    
    static func debugSimulateSilentPush() async {
        
        let testUserInfo: [AnyHashable: Any] = [
            
            "aps": ["content-available": 1],
            
            "taskID": "8B4A1F2C-3D4E-4A5B-9C1D-2E3F4A5B6C7D",
            
            "title": "Review teammate's edits",
            
            "assigneeName": "Marcus Webb"
            
        ]
        
        let delegate = AppDelegate()
        
        _ = await delegate.application(UIApplication.shared, didReceiveRemoteNotification: testUserInfo)
        
    }
    
    #endif
}

