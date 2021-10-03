//
//  XCTestExtention.swift
//  DemoApp
//
//  Created by Haider on 03/10/21.
//

import UIKit
import XCTest

extension XCTestCase {
    
    func waitForTimeout(for duration: TimeInterval, exceptionName name:String, callback back:((XCTestExpectation) -> Void)?) {
        
        let waitExpectation = expectation(description: name)
        back?(waitExpectation)
        // We use a buffer here to avoid flakiness with Timer on CI
        waitForExpectations(timeout: duration + 0.5)
    }
    
    func waitForVisible(_ element:XCUIElement, timeout wait:TimeInterval) {
        
        let viewExists = element.waitForExistence(timeout: wait)
        XCTAssertTrue(viewExists)
    }
    
    func fullFillExpectation(_ activityExpectation: inout XCTestExpectation?) {
        
        if activityExpectation != nil {
            activityExpectation?.fulfill()
            activityExpectation = nil
        }
    }
}
