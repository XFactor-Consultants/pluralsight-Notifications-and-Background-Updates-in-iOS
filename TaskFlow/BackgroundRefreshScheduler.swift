//
//  BackgroundRefreshScheduler.swift
//  TaskFlow
//
//  Created by Chris Hewitt on 9/1/26.
//

import Foundation
import BackgroundTasks
enum BackgroundRefreshScheduler {
    
    static let identifier = "com.xfactorconsulting.TaskFlow.refresh"
    
    static func register() {
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: identifier, using: nil) { task in
            
            handle(task as! BGAppRefreshTask)
            
        }
        
    }
    
    static func schedule() {
        
        let request = BGAppRefreshTaskRequest(identifier: identifier)
        
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        
        try? BGTaskScheduler.shared.submit(request)
        
    }
    
    private static func handle(_ task: BGAppRefreshTask) {
        
        schedule()
        
        task.expirationHandler = {
            
            task.setTaskCompleted(success: false)
            
        }
        
        print("Pretending to pull teammate edits...")
        
        task.setTaskCompleted(success: true)
        
    }
    
}

