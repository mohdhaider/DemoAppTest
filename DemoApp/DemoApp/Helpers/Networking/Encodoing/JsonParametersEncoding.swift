//
//  JsonParametersEncoding.swift
//  SearchApp
//
//  Created by Haider on 25/09/21.
//

import Foundation

struct JsonParametersEncoding: EncodingProtocol {
    
    func encode(_ request: inout URLRequest, parameters: Parameters) throws {
        
        guard let _ = request.url else { throw ParametersEncodingErrors.urlNotAvailable }
        
        do {
            let jsonObj = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            request.httpBody = jsonObj
            
            if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        } catch {
            throw ParametersEncodingErrors.jsonEncodingFailed
        }
    }
}
