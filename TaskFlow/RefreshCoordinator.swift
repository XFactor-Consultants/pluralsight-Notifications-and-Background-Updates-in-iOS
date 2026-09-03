//
//  RefreshCoordinator.swift
//  TaskFlow
//
//  Created by Chris Hewitt on 9/2/26.
//

enum RefreshCoordinator {
    
    static func refresh() async {
        
        try? await Task.sleep(for: .seconds(1))
        
        print("Refresh found: Task update pulled from mocked backend")
        
    }
    
}
