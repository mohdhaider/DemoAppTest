//
//  NetworkIntractor.swift
//  SearchApp
//
//  Created by Haider on 25/09/21.
//

import Foundation

typealias NetworkRequestCompletion = (_ data:Data?, _ response: URLResponse?, _ error: Error?) -> ()

protocol InteractorProtocol {
    associatedtype InfoType
    
    func request(_ requestInfo:InfoType, completion completionBlock: @escaping NetworkRequestCompletion)
}

class NetworkIntractor<Info: RequestInfo>: InteractorProtocol {
    
    private var task: URLSessionDataTask?
    
    func request(_ requestInfo: Info, completion completionBlock: @escaping NetworkRequestCompletion) {
        
        let session = URLSession.shared
        var request = URLRequest(url: requestInfo.requestURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
        
        do {
            try buildRequest(&request, requestInfo: requestInfo)
            
            task = session.dataTask(with: request) { (data, response, error) in
                completionBlock(data, response, error)
            }
            
            task?.resume()
        } catch {
            completionBlock(nil, nil, error)
        }
    }
    
    private func buildRequest(_ request: inout URLRequest, requestInfo: Info) throws {
        
        switch requestInfo.requestType {
        case .requestWithParameters(let encoding, let urlParameters, let bodyParameters, let headers):
            
            try encoding.encode(&request, urlParameters: urlParameters, bodyParameters: bodyParameters)
            addHeaders(request: &request, headers)
        default:
            break
        }
    }
    
    private func addHeaders(request  req: inout URLRequest, _ headers: Parameters) {
        for (key, value) in headers {
            req.setValue("\(value)", forHTTPHeaderField: key)
        }
    }
}
