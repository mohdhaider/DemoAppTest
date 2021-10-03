//
//  RequestInfo.swift
//  DemoApp
//
//  Created by Haider on 02/10/21.
//

import Foundation

enum HTTPType: String {
    case get = "GET"
    case post = "POST"
}

protocol RequestInfo {
    var httpType: HTTPType {get}
    var requestURL: URL {get}
    var requestType: RequestFeature {get}
}
