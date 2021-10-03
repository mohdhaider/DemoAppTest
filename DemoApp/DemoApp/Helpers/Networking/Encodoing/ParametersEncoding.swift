//
//  ParametersEncoding.swift
//  DemoApp
//
//  Created by Haider on 02/10/21.
//

import Foundation

typealias Parameters = [String:Any]

protocol EncodingProtocol {
    func encode(_ request: inout URLRequest, parameters: Parameters) throws
}

enum ParametersEncodign {
    case urlEncoding
    
    func encode(_ request: inout URLRequest, urlParameters urlParams: Parameters, bodyParameters bodyParams: Parameters) throws {
        
        switch self {
        case .urlEncoding:
            try UrlParametersEncoding().encode(&request, parameters: urlParams)
        }
    }
}

enum ParametersEncodingErrors: String, Error {
    case urlNotAvailable = "Url Not Available"
    case urlEncodingFailed = "Url Encoding Failed"
    case jsonEncodingFailed = "Json Encoding Failed"
}
