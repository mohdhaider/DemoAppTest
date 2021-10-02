//
//  ErrorAdditions.swift
//  DemoApp
//
//  Created by Haider on 02/10/21.
//

import UIKit

extension Error {
    
    func isNoInternetError() -> Bool {
        
        var success = false
        let val = (self as NSError).code
        
        switch val {
        case NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost, NSURLErrorNetworkConnectionLost, NSURLErrorResourceUnavailable, NSURLErrorNotConnectedToInternet, NSURLErrorDataNotAllowed:
            
            success = true
        default:
            break
        }
        
        return success
    }
}
