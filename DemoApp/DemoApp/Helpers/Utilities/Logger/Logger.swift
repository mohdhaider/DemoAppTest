//
//  Logger.swift
//  DemoApp
//
//  Created by Haider on 03/10/21.
//

import UIKit

struct Logger {
    
    static func printLog(_ val:Any?) {
        
        #if DEBUG
        print(val ?? "")
        #endif
    }
}
