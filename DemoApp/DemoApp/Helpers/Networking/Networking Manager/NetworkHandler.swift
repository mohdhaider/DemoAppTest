//
//  NetworkHandler.swift
//  DemoApp
//
//  Created by Haider on 03/10/21.
//

import Foundation

let networkRequestTimeout:Double = 60.0

typealias NetworkRequestCompletion = (_ data:Data?, _ response: URLResponse?, _ error: Error?) -> ()

protocol NetworkHandlerProtocol {
    associatedtype InfoType
    
    func request(_ requestInfo:InfoType, completion completionBlock: @escaping NetworkRequestCompletion)
}

class NetworkHandler<Info: RequestInfo>: NetworkHandlerProtocol {
    
    private var task: URLSessionDataTask?
    
    func request(_ requestInfo: Info, completion completionBlock: @escaping NetworkRequestCompletion) {
        
        let session = URLSession.shared
        var request = URLRequest(url: requestInfo.requestURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: networkRequestTimeout)
        
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
        case .requestWithParameters(let encoding, let urlParameters, let bodyParameters, _):
            
            try encoding.encode(&request, urlParameters: urlParameters, bodyParameters: bodyParameters)
        }
    }
}

