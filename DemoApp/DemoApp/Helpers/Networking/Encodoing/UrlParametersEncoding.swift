//
//  UrlParametersEncoding.swift
//  SearchApp
//
//  Created by Haider on 25/09/21.
//

import Foundation

struct UrlParametersEncoding: EncodingProtocol {
    
    func encode(_ request: inout URLRequest, parameters: Parameters) throws {
        
        guard let url = request.url else { throw ParametersEncodingErrors.urlNotAvailable }
        
        if var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            
            components.queryItems = [URLQueryItem]()
            
            for (key, value) in parameters {
                let item = URLQueryItem(name: key, value: "\(value)")
                components.queryItems?.append(item)
            }
            
            request.url = components.url
            
            if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }
        else  {
            throw ParametersEncodingErrors.urlEncodingFailed
        }
    }
}
