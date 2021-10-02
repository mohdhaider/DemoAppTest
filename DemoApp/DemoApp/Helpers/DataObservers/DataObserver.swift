//
//  DataObserver.swift
//  SearchApp
//
//  Created by Haider on 25/09/21.
//

import Foundation

struct BindingBox<Element> {
    
    typealias Listener = (Element) -> ()
    private var listeners = [Listener]()
    
    var value: Element {
        didSet{
            listeners.forEach{ $0(value) }
        }
    }
    
    init(_ val: Element) {
        value = val
    }
    
    mutating func bind(_ listener: Listener?) {
        
        guard let listenerAvail = listener else { return }
        
        listeners.append(listenerAvail)
    }
    
    mutating func singleBind(_ listener: Listener?) {
        
        listeners.removeAll()
        guard let listenerAvail = listener else { return }
        listeners.append(listenerAvail)
    }
}
