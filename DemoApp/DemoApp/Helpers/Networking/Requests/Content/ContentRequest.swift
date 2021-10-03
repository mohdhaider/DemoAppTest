//
//  ContentRequest.swift
//  DemoApp
//
//  Created by Haider on 03/10/21.
//

import Foundation

enum ContentRequest {
    case fetchData(page: Int)
}

extension ContentRequest : RequestInfo {
    
    var requestURL: URL {
        
        let urlStr = Apis.baseUrl.rawValue + Apis.taskApi.rawValue
        
        guard let url = URL(string: urlStr) else { fatalError("Unable to configure url") }
        return url
    }
    
    var requestType: RequestFeature {
        
        let headers =  Parameters()
        let bodyParams =  Parameters()
        var urlParams =  Parameters()
        
        switch self {
        case .fetchData(let page):
            urlParams["page"] = page
        }
        
        return .requestWithParameters(encoding: .urlEncoding, urlParameters: urlParams, bodyParameters: bodyParams, headers: headers)
    }
}
