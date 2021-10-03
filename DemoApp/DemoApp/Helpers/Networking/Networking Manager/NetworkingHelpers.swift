//
//  NetworkingHelpers.swift
//  DemoApp
//
//  Created by Haider on 03/10/21.
//

import Foundation

struct NetworkingHelpers {
    
    func fetchContent(_ interactor:NetworkHandler<ContentRequest>,_ info: ContentRequest, completionBlock: @escaping NetworkRequestCompletion) {
        
        interactor.request(info) { (data, response, error) in
            
            completionBlock(data, response, error)
        }
    }
}
