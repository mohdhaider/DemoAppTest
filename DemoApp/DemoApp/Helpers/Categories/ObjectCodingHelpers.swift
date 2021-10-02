//
//  ObjectCodinHelpers.swift
//  SearchApp
//
//  Created by Haider on 25/09/21.

//

import Foundation

protocol DecodingHelper {
    
    associatedtype Keys: CodingKey
    
    static func getStringValue(_ container: KeyedDecodingContainer<Keys>, key: Keys) -> String?
    
    static func getIntValue(_ container: KeyedDecodingContainer<Keys>, key: Keys) -> Int
}

extension DecodingHelper {
    
    static func getStringValue(_ container: KeyedDecodingContainer<Keys>, key: Keys) -> String? {
        var str:String?
        
        if let obj = try? container.decode(String.self, forKey: key) {
            str = obj
        }
        else if let obj = try? container.decode(Int.self, forKey: key){
            str = String(obj)
        }
        return str
    }
    
    static func getIntValue(_ container: KeyedDecodingContainer<Keys>, key: Keys) -> Int {
        var val: Int = 0
        
        if let obj = try? container.decode(String.self, forKey: key),
            let intVal = Int(obj){
            val = intVal
        }
        else if let obj = try? container.decode(Int.self, forKey: key){
            val = obj
        }
        return val
    }
}
