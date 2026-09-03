//
//  BackgroundArchiveScheduler.swift
//  TaskFlow
//
//  Created by Chris Hewitt on 9/1/26.
//

import BackgroundTasks
enum BackgroundArchiveScheduler {
    
    static let identifier = "com.xfactorconsulting.TaskFlow.archive"
    
    static func register() {
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: identifier, using: nil) { task in
            
            handle(task as! BGProcessingTask)
            
        }
        
    }
    
    static func schedule() {
        
        let request = BGProcessingTaskRequest(identifier: identifier)
        
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60)
        
        request.requiresNetworkConnectivity = false
        request.requiresExternalPower = true
        try? BGTaskScheduler.shared.submit(request)
        
    }
    
    private static func handle(_ task: BGProcessingTask) {
        
        schedule()
        
        var isCancelled = false
        task.expirationHandler = {
            
            isCancelled = true
        }
        
        // Archiving happens one task at a time, so a cancellation
        
        // between tasks never leaves a single task half-written.
        
        for _ in 1...5 {
            
            guard !isCancelled else {
                
                task.setTaskCompleted(success: false)
                
                return
            }
            
            // Archive one completed task here.
            
        }
        
        HistorySyncManager.startSync()
        task.setTaskCompleted(success: true)
        
    }
    
}
