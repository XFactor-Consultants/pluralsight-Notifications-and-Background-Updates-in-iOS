//
//  TaskAssignmentPayload.swift
//  TaskFlow
//
//  Created by Chris Hewitt on 8/31/26.
//
import Foundation

struct TaskAssignmentPayload {
    
    let taskID: UUID
    let title: String
    let assigneeName: String
    init?(userInfo: [AnyHashable: Any]) {
        
        guard let idString = userInfo["taskID"] as? String,
              
                let id = UUID(uuidString: idString),
              
                let title = userInfo["title"] as? String,
              
                let assignee = userInfo["assigneeName"] as? String else {
            
            return nil
        }
        
        taskID = id
        
        self.title = title
        assigneeName = assignee
    }
    
}

