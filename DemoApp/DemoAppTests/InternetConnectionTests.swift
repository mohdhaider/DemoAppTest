//
//  InternetConnectionTests.swift
//  DemoAppTests
//
//  Created by Haider on 03/10/21.
//

import XCTest
@testable import DemoApp

class InternetConnectionTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInternetConnectionStatusChecks() throws {
        
        var activityExpectation: XCTestExpectation?
        
        let name = "Internet connection status check"
        let expectationName = "\(name) waiting"
        
        XCTContext.runActivity(named: name) { _ in
            
            waitForTimeout(for: 10,
                              exceptionName: expectationName) { expectation in
                
                activityExpectation = expectation
                
                InternetHandler.shared.checkInternetConnectionCases {[weak self] status in
                    
                    if status {
                        self?.fullFillExpectation(&activityExpectation)
                    }
                }
            }
        }
    }
    
    func testReachabilityStatusIfWifiAvailable() throws {
        
        var activityExpectation: XCTestExpectation?
        
        let name = "Reachability Status If Wifi Available"
        let expectationName = "\(name) waiting"
        
        XCTContext.runActivity(named: name) { _ in
            
            waitForTimeout(for: 10,
                              exceptionName: expectationName) {[weak self] expectation in
                
                activityExpectation = expectation
                
                let status = InternetHandler.shared.checkReachabilityStatusIfWifiAvailable()
                
                if status {
                    self?.fullFillExpectation(&activityExpectation)
                }
            }
        }
    }
    
    func testReachabilityStatusIfCellularAvailable() throws {
        
        var activityExpectation: XCTestExpectation?
        
        let name = "Reachability Status If Cellular Available"
        let expectationName = "\(name) waiting"
        
        XCTContext.runActivity(named: "Internet connection status check") { _ in
            
            waitForTimeout(for: 10,
                              exceptionName: expectationName) {[weak self] expectation in
                
                activityExpectation = expectation
                
                let status = InternetHandler.shared.checkReachabilityStatusIfCellularAvailable()
                
                if status {
                    self?.fullFillExpectation(&activityExpectation)
                }
            }
        }
    }
    
    func testNoInternetIfConnectionUnavailable() throws {
        
        var activityExpectation: XCTestExpectation?
        
        let name = "No Internet If Connection Unavailable"
        let expectationName = "\(name) waiting"
        
        XCTContext.runActivity(named: name) { _ in
            
            waitForTimeout(for: 10,
                              exceptionName: expectationName) {[weak self] expectation in
                
                activityExpectation = expectation
                
                let status = InternetHandler.shared.checkNoInternetIfConnectionUnavailable()
                
                if status {
                    self?.fullFillExpectation(&activityExpectation)
                }
            }
        }
    }
}
