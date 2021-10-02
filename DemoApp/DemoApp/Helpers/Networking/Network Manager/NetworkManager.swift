//
//  NetworkManager.swift
//  SearchApp
//
//  Created by Haider on 25/09/21.
//

import Foundation

struct NetworkManager {
    
    func fetchContent(_ interactor:NetworkIntractor<TaskRequest>,_ info: TaskRequest, completionBlock: @escaping NetworkRequestCompletion) {
        
        interactor.request(info) { (data, response, error) in
            
            completionBlock(data, response, error)
        }
    }
}
