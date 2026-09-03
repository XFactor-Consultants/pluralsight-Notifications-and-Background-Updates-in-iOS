//
//  HistorySyncManager.swift
//  TaskFlow
//
//  Created by Chris Hewitt on 9/2/26.
//

import Foundation
enum HistorySyncManager {
    
    static let sessionIdentifier = "com.xfactorconsulting.TaskFlow.historySync"
    
    static func startSync() {
        
        let config = URLSessionConfiguration.background(withIdentifier: sessionIdentifier)
        
        let session = URLSession(configuration: config, delegate: nil, delegateQueue: nil)
        
        let url = URL(string: "https://example.com/task-history")!
        
        session.downloadTask(with: url).resume()
    }
}
